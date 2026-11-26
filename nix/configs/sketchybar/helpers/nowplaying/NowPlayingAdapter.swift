// SPDX-License-Identifier: MIT
// Reads the system Now Playing session for Sketchybar.

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

private var watching = false
private var readAt: ((TimeInterval) -> Void)?
private let emissionLock = NSLock()

private let mediaRemoteHandle = dlopen(
    "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote",
    RTLD_LAZY
)

private let sketchybarBin: String = {
    let user = NSUserName()
    for path in [
        "/etc/profiles/per-user/\(user)/bin/sketchybar",
        "/run/current-system/sw/bin/sketchybar"
    ] where FileManager.default.isExecutableFile(atPath: path) {
        return path
    }
    return "sketchybar"
}()

func function<T>(_ handle: UnsafeMutableRawPointer?, _ name: String, as type: T.Type) -> T? {
    guard let handle, let symbol = dlsym(handle, name) else { return nil }
    return unsafeBitCast(symbol, to: type)
}

func function<T>(_ name: String, as type: T.Type) -> T? {
    function(mediaRemoteHandle, name, as: type)
}

func charWidth(_ scalar: Unicode.Scalar) -> Int {
    let cp = scalar.value
    if (0x0300...0x036F).contains(cp) || (0x200B...0x200F).contains(cp) || (0xFE00...0xFE0F).contains(cp) {
        return 0
    }
    if (0x1100...0x115F).contains(cp)
        || (0x2E80...0xA4CF).contains(cp)
        || (0xAC00...0xD7A3).contains(cp)
        || (0xF900...0xFAFF).contains(cp)
        || (0xFE10...0xFE19).contains(cp)
        || (0xFE30...0xFE6F).contains(cp)
        || (0xFF01...0xFF60).contains(cp)
        || (0xFFE0...0xFFE6).contains(cp)
        || (0x1F300...0x1FAFF).contains(cp)
        || (0x20000...0x2FA1F).contains(cp) {
        return 2
    }
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

private var lastDrawing = ""
private var lastLabel = ""

func updateSketchybar(drawing: Bool, label: String, displayID: String?, pid: Int32?) {
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

    guard drawStr != lastDrawing || label != lastLabel else { return }
    lastDrawing = drawStr
    lastLabel = label

    let task = Process()
    task.executableURL = URL(fileURLWithPath: sketchybarBin)
    task.arguments = drawing
        ? ["--set", "media.cover", "drawing=on", "label=\(label)"]
        : ["--set", "media.cover", "drawing=off"]
    task.terminationHandler = { _ in }
    try? task.run()
}

func encodedReply(_ reply: [String: Any]) -> Data {
    let finite = reply.filter { ($0.value as? Double)?.isFinite != false }
    guard JSONSerialization.isValidJSONObject(finite),
          let data = try? JSONSerialization.data(withJSONObject: finite) else {
        return Data("{\"error\":\"json\"}".utf8)
    }
    return data
}

func emit(_ reply: [String: Any]) {
    let data = encodedReply(reply)
    emissionLock.lock()
    defer { emissionLock.unlock() }
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data("\n".utf8))
}

@_cdecl("sketchybar_now_playing_get")
public func sketchybarNowPlayingGet() {
    guard let getInfo = function("MRMediaRemoteGetNowPlayingInfo", as: InfoFunction.self) else {
        emit(["error": "MRMediaRemoteGetNowPlayingInfo unavailable"])
        return
    }

    let selected = NotchNativePlayback.select()
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

    func set(_ key: String, _ value: Any?) {
        guard let value else { return }
        lock.lock()
        reply[key] = value
        lock.unlock()
    }

    group.enter()
    let receiveInfo: InfoCallback = { info in
        let info = (info as? [String: Any]) ?? [:]
        if watching {
            set("itemIdentifier", info["kMRMediaRemoteNowPlayingInfoContentItemIdentifier"] as? String)
        }
        for key in [
            "kMRMediaRemoteNowPlayingInfoTitle",
            "kMRMediaRemoteNowPlayingInfoArtist",
            "kMRMediaRemoteNowPlayingInfoAlbum"
        ] {
            set(key, info[key] as? String)
        }
        if !watching {
            set("kMRMediaRemoteNowPlayingInfoDuration",
                (info["kMRMediaRemoteNowPlayingInfoDuration"] as? NSNumber)?.doubleValue)
            set("kMRMediaRemoteNowPlayingInfoElapsedTime",
                (info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? NSNumber)?.doubleValue)
            set("kMRMediaRemoteNowPlayingInfoPlaybackRate",
                (info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? NSNumber)?.doubleValue)
        }
        group.leave()
    }

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
    } else {
        getInfo(queue, receiveInfo)
        if let getPID = function("MRMediaRemoteGetNowPlayingApplicationPID", as: PIDFunction.self) {
            group.enter()
            getPID(queue) { pid in set("pid", pid); group.leave() }
        }
        if let getDisplayID = function("MRMediaRemoteGetNowPlayingApplicationDisplayID", as: DisplayIDFunction.self) {
            group.enter()
            getDisplayID(queue) { id in set("displayID", id as String?); group.leave() }
        }
        if let getIsPlaying = function("MRMediaRemoteGetNowPlayingApplicationIsPlaying", as: IsPlayingFunction.self) {
            group.enter()
            getIsPlaying(queue) { isPlaying in set("isPlaying", isPlaying); group.leave() }
        }
    }

    if watching {
        guard group.wait(timeout: .now() + 2) == .success else {
            emit(["error": "metadata timeout"])
            exit(1)
        }
    } else {
        group.wait()
    }
    _ = state.wait(timeout: .now() + 0.2)

    lock.lock()
    let snapshot = reply
    lock.unlock()

    if watching {
        _ = NotchNativePlayback.publish(selected, info: snapshot)
        let title = (snapshot["kMRMediaRemoteNowPlayingInfoTitle"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let artist = (snapshot["kMRMediaRemoteNowPlayingInfoArtist"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let displayID = snapshot["displayID"] as? String
        let pid = (snapshot["pid"] as? NSNumber)?.int32Value

        let drawing = !title.isEmpty
        let label: String
        if drawing {
            let raw = artist.isEmpty ? title : "\(artist) - \(title)"
            label = truncateVisual(raw, maxWidth: 50)
        } else {
            label = ""
        }
        updateSketchybar(drawing: drawing, label: label, displayID: displayID, pid: pid)
    } else {
        emit(snapshot)
    }
}

@_cdecl("sketchybar_now_playing_watch_all")
public func sketchybarNowPlayingWatchAll() {
    NotchNativePlayback.includeOtherPlayers = true
    sketchybarNowPlayingWatch()
}

@_cdecl("sketchybar_now_playing_watch")
public func sketchybarNowPlayingWatch() {
    typealias Register = @convention(c) (DispatchQueue) -> Void
    guard let register = function("MRMediaRemoteRegisterForNowPlayingNotifications", as: Register.self) else {
        emit(["error": "notifications unavailable"])
        return
    }
    watching = true
    register(.main)
    let reader = DispatchQueue(label: "sketchybar.nowplaying.watch")
    var pending: DispatchWorkItem?
    let names = [
        "kMRMediaRemoteNowPlayingInfoDidChangeNotification",
        "kMRMediaRemoteNowPlayingApplicationDidChangeNotification",
        "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification",
        "kMRMediaRemotePlayerNowPlayingInfoDidChangeNotification",
        "kMRMediaRemoteNowPlayingPlayerStateDidChange",
        "kMRMediaRemoteNowPlayingApplicationClientStateDidChange",
        "kMRMediaRemotePlayerIsPlayingDidChangeNotification"
    ] + [NotchNativePlayback.stringConstant("kMRMediaRemotePlayerPlaybackStateDidChangeNotification")].compactMap { $0 }

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
