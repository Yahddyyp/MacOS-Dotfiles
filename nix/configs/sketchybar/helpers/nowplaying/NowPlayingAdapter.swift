// SPDX-License-Identifier: MIT
// Reads the system Now Playing session and prints it as one JSON line.
//
// Since macOS 15.4 MediaRemote answers `MRMediaRemoteGetNowPlayingInfo` with
// nothing unless the calling process carries Apple's own signature, so ordinary
// user processes cannot read it directly. `/usr/bin/perl` is a platform
// binary and can; `helpers/now-playing.pl` loads this library into perl
// with DynaLoader and calls `sketchybar_now_playing_get` or `watch_all`.

import AppKit
import Foundation

private typealias InfoCallback = @convention(block) (NSDictionary?) -> Void
private typealias InfoFunction = @convention(c) (DispatchQueue, @escaping InfoCallback) -> Void
private typealias PIDCallback = @convention(block) (Int32) -> Void
private typealias PIDFunction = @convention(c) (DispatchQueue, @escaping PIDCallback) -> Void
private typealias DisplayIDCallback = @convention(block) (NSString?) -> Void
private typealias DisplayIDFunction = @convention(c) (DispatchQueue, @escaping DisplayIDCallback) -> Void
private typealias IsPlayingCallback = @convention(block) (Bool) -> Void
private typealias IsPlayingFunction = @convention(c) (DispatchQueue, @escaping IsPlayingCallback) -> Void

// Only the watch process enables this.
private var watching = false
/// Watch only: where the last reply put its recording, by the sample it read.
private var lastPosition: (revision: UUID, sample: Double, timestamp: Date?, elapsed: Double, rate: Double, at: Date)?
/// Set by the watch process: schedules another read at a system uptime.
private var readAt: ((TimeInterval) -> Void)?

func function<T>(_ handle: UnsafeMutableRawPointer?, _ name: String, as type: T.Type) -> T? {
    guard let handle, let symbol = dlsym(handle, name) else { return nil }
    return unsafeBitCast(symbol, to: type)
}

private let emissionLock = NSLock()

func findSketchybar() -> String {
    let user = NSUserName()
    let candidate = "/etc/profiles/per-user/\(user)/bin/sketchybar"
    if FileManager.default.isExecutableFile(atPath: candidate) {
        return candidate
    }
    let systemCandidate = "/run/current-system/sw/bin/sketchybar"
    if FileManager.default.isExecutableFile(atPath: systemCandidate) {
        return systemCandidate
    }
    return "sketchybar"
}

func charWidth(_ scalar: Unicode.Scalar) -> Int {
    let cp = scalar.value
    if (cp >= 0x0300 && cp <= 0x036F) || (cp >= 0x200B && cp <= 0x200F) || (cp >= 0xFE00 && cp <= 0xFE0F) { return 0 }
    if (cp >= 0x1100 && cp <= 0x115F)
        || (cp >= 0x2E80 && cp <= 0xA4CF)
        || (cp >= 0xAC00 && cp <= 0xD7A3)
        || (cp >= 0xF900 && cp <= 0xFAFF)
        || (cp >= 0xFE10 && cp <= 0xFE19)
        || (cp >= 0xFE30 && cp <= 0xFE6F)
        || (cp >= 0xFF01 && cp <= 0xFF60)
        || (cp >= 0xFFE0 && cp <= 0xFFE6)
        || (cp >= 0x1F300 && cp <= 0x1FAFF)
        || (cp >= 0x20000 && cp <= 0x2FA1F) { return 2 }
    return 1
}

func truncateVisual(_ str: String, maxWidth: Int = 50) -> String {
    var totalW = 0
    for char in str {
        for scalar in char.unicodeScalars { totalW += charWidth(scalar) }
    }
    if totalW <= maxWidth { return str }

    let limit = maxWidth - 3
    var res = ""
    var curW = 0
    for char in str {
        var charW = 0
        for scalar in char.unicodeScalars { charW += charWidth(scalar) }
        if curW + charW > limit { break }
        res.append(char)
        curW += charW
    }
    while res.hasSuffix(" ") { res.removeLast() }
    return res + "..."
}

private var lastDrawing: String = ""
private var lastLabel: String = ""

func updateSketchybar(drawing: Bool, label: String, displayID: String?, pid: Int32?) {
    let sketchybar = findSketchybar()
    let drawStr = drawing ? "on" : "off"

    if drawing {
        if let displayID, !displayID.isEmpty {
            try? displayID.write(toFile: "/tmp/sketchybar_media_app", atomically: true, encoding: .utf8)
        }
        if let pid, pid > 0 {
            try? "\(pid)".write(toFile: "/tmp/sketchybar_media_pid", atomically: true, encoding: .utf8)
        }
    } else {
        try? FileManager.default.removeItem(atPath: "/tmp/sketchybar_media_app")
        try? FileManager.default.removeItem(atPath: "/tmp/sketchybar_media_pid")
    }

    if drawStr != lastDrawing || label != lastLabel {
        lastDrawing = drawStr
        lastLabel = label
        let task = Process()
        task.executableURL = URL(fileURLWithPath: sketchybar)
        if drawing {
            task.arguments = ["--set", "media.cover", "drawing=on", "label=\(label)"]
        } else {
            task.arguments = ["--set", "media.cover", "drawing=off"]
        }
        try? task.run()
    }
}

/// JSONSerialization raises an Objective-C exception on NaN or infinity,
/// which `try?` cannot catch. A player can report either for a live stream,
/// so such a number is left out; any other invalid value reads as an error.
func encodedReply(_ reply: [String: Any]) -> Data {
    let finite = reply.filter { ($0.value as? Double)?.isFinite != false }
    guard JSONSerialization.isValidJSONObject(finite),
          let data = try? JSONSerialization.data(withJSONObject: finite) else {
        return Data("{\"error\":\"json\"}".utf8)
    }
    return data
}

/// Where a song sampled `age` seconds ago is now, and the rate the island
/// moves it at. A player can update its rate a step late or never, so its own
/// playing state, when known, wins over a rate that contradicts it. The song
/// then holds still at the sample, or at `continuing`, where the last reply
/// had it while the player kept the same sample. A playing song without a
/// rate may be buffering, so it moves only once the player reports one.
func playbackPosition(elapsed: Double, age: TimeInterval, rate: Double, isPlaying: Bool?,
                      continuing: Double? = nil) -> (elapsed: Double, rate: Double) {
    let rate = max(0, rate)
    guard let isPlaying, isPlaying != (rate > 0) else { return (elapsed + age * rate, rate) }
    return (continuing ?? elapsed, 0)
}

/// Writes where `sample` puts the song into the reply. Any player's change
/// reads the followed one again, and a sample it has not replaced must not
/// send its song back to where that sample was taken.
func settlePosition(_ reply: inout [String: Any], sample: (elapsed: Double, timestamp: Date?),
                    revision: UUID?, now: Date = Date()) {
    let isPlaying = reply["isPlaying"] as? Bool
    let continuing = lastPosition.flatMap { last -> Double? in
        guard last.revision == revision, last.sample == sample.elapsed, last.timestamp == sample.timestamp else { return nil }
        return last.elapsed + max(0, now.timeIntervalSince(last.at)) * last.rate
    }
    let settled = playbackPosition(elapsed: sample.elapsed,
                                   age: sample.timestamp.map { max(0, now.timeIntervalSince($0)) } ?? 0,
                                   rate: reply["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? 0,
                                   isPlaying: isPlaying, continuing: continuing)
    reply["kMRMediaRemoteNowPlayingInfoElapsedTime"] = settled.elapsed
    if isPlaying != nil { reply["kMRMediaRemoteNowPlayingInfoPlaybackRate"] = settled.rate }
    lastPosition = revision.map { ($0, sample.elapsed, sample.timestamp, settled.elapsed, settled.rate, now) }
}

func emit(_ reply: [String: Any]) {
    let data = encodedReply(reply)
    emissionLock.lock()
    defer { emissionLock.unlock() }
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data("\n".utf8))
}

/// Entry point called from perl. Prints exactly one line and returns.
@_cdecl("sketchybar_now_playing_get")
public func sketchybarNowPlayingGet() {
    let handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY)
    guard let getInfo = function(handle, "MRMediaRemoteGetNowPlayingInfo", as: InfoFunction.self) else {
        emit(["error": "MRMediaRemoteGetNowPlayingInfo unavailable"])
        return
    }
    let selected = NotchNativePlayback.select()
    // No player may report a change while the chosen source waits for its
    // next track. Read again when that wait ends, so the release shows.
    if watching, let release = NotchNativePlayback.pendingRelease { readAt?(release) }
    if watching, selected == nil {
        NotchNativePlayback.publish(nil)
        updateSketchybar(drawing: false, label: "", displayID: nil, pid: nil)
        return
    }
    let queue = DispatchQueue(label: "sketchybar.nowplaying.adapter")
    let group = DispatchGroup()
    let lock = NSLock()
    var reply: [String: Any] = [:]
    var sample: (elapsed: Double, timestamp: Date?)?
    func set(_ key: String, _ value: Any?) {
        guard let value else { return }
        lock.lock()
        reply[key] = value
        lock.unlock()
    }

    group.enter()
    let receiveInfo: InfoCallback = { info in
        let info = (info as? [String: Any]) ?? [:]
        if watching { set("itemIdentifier", info["kMRMediaRemoteNowPlayingInfoContentItemIdentifier"] as? String) }
        for key in ["kMRMediaRemoteNowPlayingInfoTitle",
                    "kMRMediaRemoteNowPlayingInfoArtist",
                    "kMRMediaRemoteNowPlayingInfoAlbum"] {
            set(key, info[key] as? String)
        }
        set("kMRMediaRemoteNowPlayingInfoDuration",
            (info["kMRMediaRemoteNowPlayingInfoDuration"] as? NSNumber)?.doubleValue)
        if let elapsed = (info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? NSNumber)?.doubleValue {
            lock.lock()
            sample = (elapsed, info["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date)
            lock.unlock()
        }
        set("kMRMediaRemoteNowPlayingInfoPlaybackRate",
            (info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? NSNumber)?.doubleValue)
        group.leave()
    }
    // The followed player's own state, which the system's Now Playing shows.
    // Some players update their rate a step late or never, so the rate alone
    // can read a paused song as playing. A missing answer only falls back to
    // the rate, so it gets its own short wait.
    let state = DispatchGroup()
    if let selected {
        NotchNativePlayback.readInfo(selected, artwork: false, queue: queue, completion: receiveInfo)
        set("pid", selected.pid)
        set("displayID", selected.applicationBundleIdentifier ?? selected.bundleIdentifier)
        state.enter()
        NotchNativePlayback.readPlaybackState(selected, queue: queue) { isPlaying in
            set("isPlaying", isPlaying)
            state.leave()
        }
    } else { getInfo(queue, receiveInfo) }
    if selected == nil, let getPID = function(handle, "MRMediaRemoteGetNowPlayingApplicationPID", as: PIDFunction.self) {
        group.enter()
        getPID(queue) { pid in
            set("pid", pid)
            group.leave()
        }
    }
    if selected == nil, let getDisplayID = function(handle, "MRMediaRemoteGetNowPlayingApplicationDisplayID",
                                   as: DisplayIDFunction.self) {
        group.enter()
        getDisplayID(queue) { identifier in
            set("displayID", identifier as String?)
            group.leave()
        }
    }
    if selected == nil, let getIsPlaying = function(handle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying",
                                   as: IsPlayingFunction.self) {
        group.enter()
        getIsPlaying(queue) { isPlaying in
            set("isPlaying", isPlaying)
            group.leave()
        }
    }

    // One-shot callers already have an external deadline. A watched session
    // also needs a bound: a missing callback must not leave stale playback
    // visible indefinitely or accumulate further requests behind it.
    if watching {
        guard group.wait(timeout: .now() + 2) == .success else {
            emit(["error": "metadata timeout"])
            exit(1)
        }
    } else { group.wait() }
    _ = state.wait(timeout: .now() + 0.2)
    lock.lock()
    var snapshot = reply
    let position = sample
    lock.unlock()
    var revision: UUID?
    if watching, let context = NotchNativePlayback.publish(selected, info: snapshot) {
        revision = context.revision
    }
    if let position { settlePosition(&snapshot, sample: position, revision: revision) } else { lastPosition = nil }
    if watching {
        let title = (snapshot["kMRMediaRemoteNowPlayingInfoTitle"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let artist = (snapshot["kMRMediaRemoteNowPlayingInfoArtist"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let displayID = snapshot["displayID"] as? String
        let pid = (snapshot["pid"] as? NSNumber)?.int32Value

        let drawing = !title.isEmpty
        var label = ""
        if drawing {
            if !artist.isEmpty {
                label = "\(artist) - \(title)"
            } else {
                label = title
            }
            label = truncateVisual(label, maxWidth: 50)
        }
        updateSketchybar(drawing: drawing, label: label, displayID: displayID, pid: pid)
    } else {
        emit(snapshot)
    }
}

/// One adapter process while a music surface is subscribed. Native change
/// notifications replace polling.
@_cdecl("sketchybar_now_playing_watch_all")
public func sketchybarNowPlayingWatchAll() {
    NotchNativePlayback.includeOtherPlayers = true
    sketchybarNowPlayingWatch()
}

@_cdecl("sketchybar_now_playing_watch")
public func sketchybarNowPlayingWatch() {
    typealias Register = @convention(c) (DispatchQueue) -> Void
    let handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY)
    guard let register = function(handle, "MRMediaRemoteRegisterForNowPlayingNotifications", as: Register.self) else {
        emit(["error": "notifications unavailable"])
        return
    }
    watching = true
    register(.main)
    let reader = DispatchQueue(label: "sketchybar.nowplaying.watch")
    var pending: DispatchWorkItem?
    let names = ["kMRMediaRemoteNowPlayingInfoDidChangeNotification",
                 "kMRMediaRemoteNowPlayingApplicationDidChangeNotification",
                 "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification",
                 "kMRMediaRemotePlayerNowPlayingInfoDidChangeNotification",
                 "kMRMediaRemoteNowPlayingPlayerStateDidChange",
                 "kMRMediaRemoteNowPlayingApplicationClientStateDidChange",
                 // Play and pause of any player, not only the system's current one.
                 "kMRMediaRemotePlayerIsPlayingDidChangeNotification"]
        // Its name differs from the symbol's (a leading underscore on 27.2).
        + [NotchNativePlayback.stringConstant("kMRMediaRemotePlayerPlaybackStateDidChangeNotification")].compactMap { $0 }
    func refresh() {
        pending?.cancel()
        let work = DispatchWorkItem { sketchybarNowPlayingGet() }
        pending = work
        reader.asyncAfter(deadline: .now() + 0.12, execute: work)
    }
    readAt = { uptime in
        let delay = max(0, uptime - ProcessInfo.processInfo.systemUptime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { refresh() }
    }
    let observers = names.map { name in
        NotificationCenter.default.addObserver(forName: Notification.Name(name), object: nil, queue: .main) { _ in refresh() }
    }
    let termination = NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { _ in refresh() }
    reader.async { sketchybarNowPlayingGet() }
    withExtendedLifetime((observers, termination)) { RunLoop.main.run() }
}
