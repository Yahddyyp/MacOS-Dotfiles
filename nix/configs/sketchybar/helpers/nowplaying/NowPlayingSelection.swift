// SPDX-License-Identifier: MIT
// Sketchybar MediaRemote selection

import AppKit
import Foundation
import ObjectiveC

enum NotchNativePlayback {
    struct Target {
        let pid: Int32
        let bundleIdentifier: String
        let path: NSObject
        var itemIdentifier: String?
        var applicationBundleIdentifier: String?

        var isRunning: Bool {
            guard let app = NSRunningApplication(processIdentifier: pid), !app.isTerminated else { return false }
            return NotchNativePlayback.resolvedBundleIdentifier(for: app) == bundleIdentifier
        }
    }

    struct NotchPlaybackContext: Equatable {
        let pid: Int32
        let revision: UUID
    }

    private typealias ReadClientFn = @convention(c) (DispatchQueue, @escaping @convention(block) (AnyObject?) -> Void) -> Void
    private typealias ReadClientsFn = @convention(c) (DispatchQueue, @escaping @convention(block) (NSArray?) -> Void) -> Void
    private typealias PIDFn = @convention(c) (AnyObject) -> Int32
    private typealias ClientStringFn = @convention(c) (AnyObject) -> Unmanaged<CFString>?
    private typealias ReadInfoFn = @convention(c) (
        AnyObject, Bool, DispatchQueue,
        @escaping @convention(block) (NSDictionary?, UnsafeRawPointer?) -> Void
    ) -> Void
    private typealias ReadStateFn = @convention(c) (AnyObject, DispatchQueue, @escaping @convention(block) (UInt32) -> Void) -> Void

    private static let handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY)
    private static let getClient = function(handle, "MRMediaRemoteGetNowPlayingClient", as: ReadClientFn.self)
    private static let getClients = function(handle, "MRMediaRemoteGetNowPlayingClients", as: ReadClientsFn.self)
    private static let getPID = function(handle, "MRNowPlayingClientGetProcessIdentifier", as: PIDFn.self)
    private static let getName = function(handle, "MRNowPlayingClientGetDisplayName", as: ClientStringFn.self)
    private static let getParent = function(handle, "MRNowPlayingClientGetParentAppBundleIdentifier", as: ClientStringFn.self)
    private static let getPlayerInfo = function(handle, "MRMediaRemoteGetNowPlayingInfoForPlayer", as: ReadInfoFn.self)
    private static let getPlayerState = function(handle, "MRMediaRemoteGetPlaybackStateForPlayer", as: ReadStateFn.self)

    private static let callbacks = DispatchQueue(label: "sketchybar.nowplaying.selection")
    private static let lock = NSLock()
    private static var selected: Target?
    private static var identity: Identity?
    private static var context: NotchPlaybackContext?
    private static var sources: [NotchPlaybackSource] = []
    private static var selection: NotchPlaybackSource.Selection?
    private static var releaseAt: TimeInterval?

    static var includeOtherPlayers = true

    static var sourceReply: [String: Any] {
        lock.lock(); defer { lock.unlock() }
        var reply: [String: Any] = ["sources": sources.map(\.reply), "sourceIsAutomatic": selection == nil]
        reply["selectedPID"] = selection?.pid
        return reply
    }

    static var pendingRelease: TimeInterval? {
        lock.lock(); defer { lock.unlock() }
        guard selection != nil, let releaseAt, releaseAt > ProcessInfo.processInfo.systemUptime else { return nil }
        return releaseAt
    }

    static func choose(_ requested: NotchPlaybackSource.Selection?) {
        lock.lock(); defer { lock.unlock() }
        guard requested == nil || sources.contains(where: { $0.selection == requested && $0.hasTrack }) else { return }
        selection = requested
        releaseAt = nil
    }

    private struct Identity: Equatable {
        let item: String?
        let metadata: [String]

        init?(_ info: [String: Any]) {
            let title = (info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return nil }
            let identifier = info["itemIdentifier"] as? String
                ?? info["kMRMediaRemoteNowPlayingInfoContentItemIdentifier"] as? String
            item = identifier.flatMap { NotchPlaybackSource.validIdentifier($0) ? $0 : nil }
            if item != nil { metadata = []; return }
            let duration = (info["kMRMediaRemoteNowPlayingInfoDuration"] as? NSNumber)?.doubleValue
            metadata = [
                title,
                info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "",
                info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? "",
                duration.flatMap { $0.isFinite ? String($0.rounded()) : nil } ?? ""
            ]
        }
    }

    static var target: Target? {
        lock.lock(); defer { lock.unlock() }
        return selected
    }

    static func select() -> Target? {
        var discovered = false
        defer {
            if !discovered {
                lock.lock(); sources = []; lock.unlock()
            }
        }

        guard let getClient, let getPID else { return nil }
        let group = DispatchGroup()
        let clientsGroup = DispatchGroup()
        let resultsLock = NSLock()
        var systemPID: Int32?
        var clientPIDs: [Int32] = []
        var clientPresentation: [Int32: (name: String?, application: String?)] = [:]

        group.enter()
        getClient(callbacks) { client in
            resultsLock.lock()
            systemPID = client.map(getPID)
            resultsLock.unlock()
            group.leave()
        }

        if let getClients {
            clientsGroup.enter()
            getClients(callbacks) { clients in
                resultsLock.lock()
                let list = (clients as? [AnyObject] ?? []).prefix(16)
                clientPIDs = list.map(getPID)
                for client in list {
                    clientPresentation[getPID(client)] = (
                        getName?(client)?.takeUnretainedValue() as String?,
                        getParent?(client)?.takeUnretainedValue() as String?
                    )
                }
                resultsLock.unlock()
                clientsGroup.leave()
            }
        }

        guard group.wait(timeout: .now() + 0.5) == .success else { return nil }
        _ = clientsGroup.wait(timeout: .now() + 0.2)

        resultsLock.lock()
        let currentPID = systemPID
        let registeredPIDs = clientPIDs
        let presentation = clientPresentation
        resultsLock.unlock()

        let chosenPID = lock.withLock { selection?.pid }
        let musicPIDs = NSWorkspace.shared.runningApplications.filter { isMusicApp($0) }.map(\.processIdentifier)
        var applications: [NSRunningApplication] = []

        for pid in [chosenPID, currentPID, target?.pid].compactMap({ $0 }) + musicPIDs + registeredPIDs {
            guard applications.count < 16 else { break }
            if pid > 0, !applications.contains(where: { $0.processIdentifier == pid }),
               let current = NSRunningApplication(processIdentifier: pid) {
                applications.append(current)
            }
        }

        var candidates: [(Target, NotchPlaybackSource)] = []
        var states: [Int32: Bool] = [:]
        let stateReads = DispatchGroup()

        for app in applications {
            guard var candidate = makeTarget(app) else { continue }
            candidate.applicationBundleIdentifier = presentation[candidate.pid]?.application
                .flatMap { NotchPlaybackSource.validIdentifier($0) ? $0 : nil }

            stateReads.enter()
            readPlaybackState(candidate, queue: callbacks) { isPlaying in
                resultsLock.lock()
                states[candidate.pid] = isPlaying
                resultsLock.unlock()
                stateReads.leave()
            }

            group.enter()
            readInfo(candidate, artwork: false, queue: callbacks) { info in
                let source = NotchPlaybackSource(
                    pid: candidate.pid,
                    bundleIdentifier: candidate.bundleIdentifier,
                    isMusicApp: isMusicApp(app, parentBundleIdentifier: candidate.applicationBundleIdentifier),
                    isPlaying: (info?["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? NSNumber)?.doubleValue ?? 0 > 0,
                    hasTrack: (info?["kMRMediaRemoteNowPlayingInfoTitle"] as? String)?
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                    displayName: presentation[candidate.pid]?.name ?? app.localizedName
                )
                resultsLock.lock()
                candidates.append((candidate, source))
                resultsLock.unlock()
                group.leave()
            }
        }

        _ = group.wait(timeout: .now() + 1)
        _ = stateReads.wait(timeout: .now() + 0.2)

        resultsLock.lock()
        let ready = candidates.map { candidate, source in
            guard let playing = states[candidate.pid], playing != source.isPlaying else { return (candidate, source) }
            return (candidate, NotchPlaybackSource(
                pid: source.pid,
                bundleIdentifier: source.bundleIdentifier,
                isMusicApp: source.isMusicApp,
                isPlaying: playing,
                hasTrack: source.hasTrack,
                displayName: source.displayName
            ))
        }
        resultsLock.unlock()

        let now = ProcessInfo.processInfo.systemUptime
        lock.lock()
        if let selection {
            let app = NSRunningApplication(processIdentifier: selection.pid)
            let ended = app == nil || app?.isTerminated == true
                || app.map { resolvedBundleIdentifier(for: $0) } != selection.bundleIdentifier
            let lostTrack = ready.contains { $0.1.selection == selection && !$0.1.hasTrack }
            if ready.contains(where: { $0.1.selection == selection && $0.1.hasTrack }) { releaseAt = nil }
            if lostTrack, releaseAt == nil { releaseAt = now + 5 }
            let expired = releaseAt.map { now >= $0 } == true
            if ended || expired {
                self.selection = nil
                releaseAt = nil
            }
        }
        let requested = selection
        let bridging = requested != nil && releaseAt != nil
        sources = ready.map(\.1)
            .filter { $0.hasTrack || bridging && $0.selection == requested }
            .sorted { $0.pid < $1.pid }
        lock.unlock()
        discovered = true

        if let requested, !bridging,
           !ready.contains(where: { $0.1.selection == requested && $0.1.hasTrack }) { return nil }

        let source = NotchPlaybackSource.preferred(
            in: ready.map(\.1),
            previousPID: target?.pid,
            systemPID: currentPID,
            selection: requested,
            includeOtherPlayers: includeOtherPlayers
        )
        return ready.first(where: { $0.1 == source })?.0
    }

    @discardableResult
    static func publish(_ target: Target?, info: [String: Any] = [:]) -> NotchPlaybackContext? {
        lock.lock(); defer { lock.unlock() }
        guard var target, let next = Identity(info) else {
            selected = target; identity = nil; context = nil
            return nil
        }
        if selected?.pid != target.pid || selected?.bundleIdentifier != target.bundleIdentifier
            || identity != next {
            context = NotchPlaybackContext(pid: target.pid, revision: UUID())
        }
        target.itemIdentifier = next.item
        selected = target
        identity = next
        return context
    }

    static func readInfo(_ target: Target, artwork: Bool, queue: DispatchQueue,
                         completion: @escaping (NSDictionary?) -> Void) {
        guard target.isRunning, let getPlayerInfo else {
            completion(nil); return
        }
        getPlayerInfo(target.path, false, queue) { info, _ in
            completion(info)
        }
    }

    static func readPlaybackState(_ target: Target, queue: DispatchQueue, completion: @escaping (Bool?) -> Void) {
        guard target.isRunning, let getPlayerState else {
            completion(nil); return
        }
        getPlayerState(target.path, queue) { state in
            switch state {
            case 1: completion(true)
            case 2, 3, 4: completion(false)
            default: completion(nil)
            }
        }
    }

    static func stringConstant(_ name: String) -> String? {
        guard let handle, let symbol = dlsym(handle, name) else { return nil }
        return symbol.assumingMemoryBound(to: NSString?.self).pointee as String?
    }

    private static func resolvedBundleIdentifier(for app: NSRunningApplication) -> String? {
        let identifier = app.bundleIdentifier
            ?? app.bundleURL.flatMap { Bundle(url: $0)?.bundleIdentifier }
        return identifier.flatMap { NotchPlaybackSource.validIdentifier($0) ? $0 : nil }
    }

    private static func isMusicApp(_ app: NSRunningApplication, parentBundleIdentifier: String? = nil) -> Bool {
        let category = app.bundleURL.flatMap {
            Bundle(url: $0)?.object(forInfoDictionaryKey: "LSApplicationCategoryType") as? String
        }
        return NotchPlaybackSource.isMusicApplication(
            bundleIdentifier: resolvedBundleIdentifier(for: app),
            parentBundleIdentifier: parentBundleIdentifier,
            category: category
        )
    }

    private static func makeTarget(_ app: NSRunningApplication) -> Target? {
        guard !app.isTerminated, let identifier = resolvedBundleIdentifier(for: app),
              let pathClass = NSClassFromString("MRPlayerPath"),
              let clientClass = NSClassFromString("MRClient"),
              class_getClassMethod(pathClass, NSSelectorFromString("localPlayerPath")) != nil,
              class_getInstanceMethod(clientClass, NSSelectorFromString("initWithBundleIdentifier:")) != nil,
              let localPath = (pathClass as AnyObject).perform(NSSelectorFromString("localPlayerPath"))?.takeUnretainedValue() as? NSObject,
              let path = localPath.copy() as? NSObject,
              let allocation = (clientClass as AnyObject).perform(NSSelectorFromString("alloc"))?.takeRetainedValue(),
              let client = allocation.perform(NSSelectorFromString("initWithBundleIdentifier:"), with: identifier)?.takeUnretainedValue() as? NSObject else { return nil }

        typealias SetPID = @convention(c) (AnyObject, Selector, Int32) -> Void
        let setPID = NSSelectorFromString("setProcessIdentifier:")
        guard client.responds(to: setPID),
              path.responds(to: NSSelectorFromString("setClient:")),
              path.responds(to: NSSelectorFromString("setPlayer:")) else { return nil }

        unsafeBitCast(client.method(for: setPID), to: SetPID.self)(client, setPID, app.processIdentifier)
        path.perform(NSSelectorFromString("setClient:"), with: client)
        path.perform(NSSelectorFromString("setPlayer:"), with: nil)
        return Target(pid: app.processIdentifier, bundleIdentifier: identifier, path: path)
    }
}
