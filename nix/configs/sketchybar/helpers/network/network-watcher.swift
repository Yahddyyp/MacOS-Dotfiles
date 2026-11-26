import Foundation
import SystemConfiguration

let sketchybarPath: String = [
    "/run/current-system/sw/bin/sketchybar",
    "/etc/profiles/per-user/\(NSUserName())/bin/sketchybar",
].first { FileManager.default.isExecutableFile(atPath: $0) } ?? "/run/current-system/sw/bin/sketchybar"

struct NetState: Equatable {
    let connected: Bool
    let vpn: Bool
}

var lastState: NetState?

func readNetwork() -> NetState {
    let task = Process()
    let pipe = Pipe()
    task.executableURL = URL(fileURLWithPath: "/sbin/route")
    task.arguments = ["-n", "get", "1.1.1.1"]
    task.standardOutput = pipe
    task.standardError = FileHandle.nullDevice

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        return NetState(connected: false, vpn: false)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    guard let line = output.split(separator: "\n").first(where: { $0.contains("interface:") }),
          let iface = line.split(separator: ":").last?.trimmingCharacters(in: .whitespaces),
          !iface.isEmpty else {
        return NetState(connected: false, vpn: false)
    }

    return NetState(connected: true, vpn: iface.hasPrefix("utun"))
}

func pushUpdate() {
    let state = readNetwork()
    guard state != lastState else { return }
    lastState = state

    let task = Process()
    task.executableURL = URL(fileURLWithPath: sketchybarPath)
    task.arguments = [
        "--trigger", "network_update",
        "CONNECTED=\(state.connected ? 1 : 0)",
        "VPN=\(state.vpn ? 1 : 0)",
    ]
    try? task.run()
}

let pidFile = "/tmp/sketchybar_network_watcher.pid"
if let oldPidStr = try? String(contentsOfFile: pidFile, encoding: .utf8),
   let oldPid = Int32(oldPidStr.trimmingCharacters(in: .whitespacesAndNewlines)),
   oldPid != getpid() {
    kill(oldPid, SIGTERM)
}
try? "\(getpid())".write(toFile: pidFile, atomically: true, encoding: .utf8)

var context = SCDynamicStoreContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
guard let store = SCDynamicStoreCreate(nil, "sketchybar.network" as CFString, { _, _, _ in
    pushUpdate()
}, &context) else {
    exit(1)
}

let patterns = [
    "State:/Network/Global/IPv4" as CFString,
    "State:/Network/Interface/.*/IPv4" as CFString,
] as CFArray

SCDynamicStoreSetNotificationKeys(store, nil, patterns)
let runLoopSource = SCDynamicStoreCreateRunLoopSource(nil, store, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)

pushUpdate()
CFRunLoopRun()
