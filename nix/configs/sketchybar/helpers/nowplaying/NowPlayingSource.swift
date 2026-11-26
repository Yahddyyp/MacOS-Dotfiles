// SPDX-License-Identifier: MIT
// Sketchybar MediaRemote playback source selection

import Foundation

struct NotchPlaybackSource: Equatable, Sendable {
    private static let knownMusicApps: Set<String> = [
        "com.apple.Music",
        "com.apple.iTunes",
        "com.spotify.client"
    ]

    static func validIdentifier(_ string: String) -> Bool {
        !string.isEmpty && string.utf8.count <= 256
            && string.allSatisfy {
                $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "." || $0 == "-" || $0 == "_")
            }
    }

    struct Selection: Equatable, Sendable {
        let pid: Int32
        let bundleIdentifier: String

        var isValid: Bool { pid > 0 && NotchPlaybackSource.validIdentifier(bundleIdentifier) }
    }

    let pid: Int32
    let bundleIdentifier: String
    let isMusicApp: Bool
    let isPlaying: Bool
    let hasTrack: Bool
    var displayName: String? = nil

    var selection: Selection { Selection(pid: pid, bundleIdentifier: bundleIdentifier) }

    static func isMusicApplication(
        bundleIdentifier: String?,
        parentBundleIdentifier: String?,
        category: String?
    ) -> Bool {
        if category == "public.app-category.music" { return true }
        if let bundleIdentifier, knownMusicApps.contains(bundleIdentifier) { return true }
        if let parentBundleIdentifier, knownMusicApps.contains(parentBundleIdentifier) { return true }
        return false
    }

    var reply: [String: Any] {
        var value: [String: Any] = [
            "pid": pid,
            "bundleIdentifier": bundleIdentifier,
            "isMusicApp": isMusicApp,
            "isPlaying": isPlaying,
            "hasTrack": hasTrack
        ]
        if let displayName { value["displayName"] = displayName }
        return value
    }

    /// A process identifier from the adapter: a positive whole number, never a Boolean.
    static func decodePID(_ value: Any?) -> Int32? {
        guard let number = value as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(),
              let pid = Int32(exactly: number.int64Value),
              pid > 0 else { return nil }
        return pid
    }

    /// Only the chosen source is listed without a track: it stays chosen for
    /// a moment while it waits for its next one.
    static func decode(_ value: Any?, selectedPID: Int32? = nil) -> [Self] {
        guard let entries = value as? [[String: Any]], entries.count <= 16 else { return [] }
        var sources: [Self] = []
        sources.reserveCapacity(entries.count)
        var seenPIDs = Set<Int32>()

        for entry in entries {
            guard let pid = decodePID(entry["pid"]),
                  !seenPIDs.contains(pid),
                  let bundle = entry["bundleIdentifier"] as? String,
                  validIdentifier(bundle),
                  let music = entry["isMusicApp"] as? Bool,
                  let playing = entry["isPlaying"] as? Bool,
                  let track = entry["hasTrack"] as? Bool,
                  track || pid == selectedPID else { continue }

            seenPIDs.insert(pid)
            let rawName = (entry["displayName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let displayName = rawName.flatMap { !$0.isEmpty && $0.utf8.count <= 256 ? $0 : nil }

            sources.append(Self(
                pid: pid,
                bundleIdentifier: bundle,
                isMusicApp: music,
                isPlaying: playing,
                hasTrack: track,
                displayName: displayName
            ))
        }
        return sources.sorted { $0.pid < $1.pid }
    }

    /// Automatic playback follows music apps and, unless the user turns them
    /// off, other players too. A manual source choice always takes precedence.
    /// Paused music keeps its resume control when nothing eligible is playing,
    /// except that a followed player that is not a music app keeps its place
    /// while paused.
    static func preferred(
        in sources: [Self],
        previousPID: Int32?,
        systemPID: Int32?,
        selection: Selection? = nil,
        includeOtherPlayers: Bool = true
    ) -> Self? {
        let available = sources.filter { $0.pid > 0 && $0.hasTrack }

        // An explicit choice remains controllable while paused, even if another
        // source is playing. Without a track, the automatic order fills in.
        if let selection, let chosen = available.first(where: { $0.selection == selection }) {
            return chosen
        }

        let music = available.filter(\.isMusicApp)
        let other = includeOtherPlayers ? available.filter { !$0.isMusicApp } : []

        let tiers = [
            music.filter(\.isPlaying),
            other.filter(\.isPlaying),
            other.filter { $0.pid == previousPID },
            music
        ]

        for candidates in tiers {
            if let previous = candidates.first(where: { $0.pid == previousPID }) { return previous }
            if let current = candidates.first(where: { $0.pid == systemPID }) { return current }
            if let lowestPID = candidates.min(by: { $0.pid < $1.pid }) { return lowestPID }
        }

        return includeOtherPlayers ? available.first { $0.pid == systemPID } : nil
    }
}
