import Foundation
import IOKit.ps

let sketchybarPath: String = [
    "/run/current-system/sw/bin/sketchybar",
    "/etc/profiles/per-user/\(NSUserName())/bin/sketchybar",
].first { FileManager.default.isExecutableFile(atPath: $0) } ?? "/run/current-system/sw/bin/sketchybar"

struct BatterySnapshot: Equatable {
    let percentage: Int
    let isCharging: Bool
    let timeRemaining: Int
}

var lastSnapshot: BatterySnapshot?

func readBattery() -> BatterySnapshot? {
    guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
          let list = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef] else {
        return nil
    }

    for source in list {
        guard let desc = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any],
              let type = desc[kIOPSTypeKey] as? String,
              type == kIOPSInternalBatteryType else {
            continue
        }

        let current = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
        let maxCap = desc[kIOPSMaxCapacityKey] as? Int ?? 100
        let pct = maxCap > 0 ? Int((Double(current) / Double(maxCap) * 100.0).rounded()) : 0
        let powerState = desc[kIOPSPowerSourceStateKey] as? String ?? ""
        let isAC = (powerState == kIOPSACPowerValue)
        let timeToEmpty = desc[kIOPSTimeToEmptyKey] as? Int ?? -1

        return BatterySnapshot(
            percentage: pct,
            isCharging: isAC,
            timeRemaining: isAC ? -1 : timeToEmpty
        )
    }
    return nil
}

func pushUpdate() {
    guard let snap = readBattery(), snap != lastSnapshot else { return }
    lastSnapshot = snap

    let task = Process()
    task.executableURL = URL(fileURLWithPath: sketchybarPath)
    task.arguments = [
        "--trigger", "battery_update",
        "PERCENTAGE=\(snap.percentage)",
        "CHARGING=\(snap.isCharging ? 1 : 0)",
        "TIME_REMAINING=\(snap.timeRemaining)",
    ]
    try? task.run()
}

let pidFile = "/tmp/sketchybar_battery_watcher.pid"
if let oldPidStr = try? String(contentsOfFile: pidFile, encoding: .utf8),
   let oldPid = Int32(oldPidStr.trimmingCharacters(in: .whitespacesAndNewlines)),
   oldPid != getpid() {
    kill(oldPid, SIGTERM)
}
try? "\(getpid())".write(toFile: pidFile, atomically: true, encoding: .utf8)

let runLoopSource = IOPSNotificationCreateRunLoopSource({ _ in
    pushUpdate()
}, nil).takeRetainedValue()

CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
pushUpdate()
CFRunLoopRun()
