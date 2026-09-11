import CoreAudio
import Foundation

final class VolumeManager {
    private let systemObject = AudioObjectID(kAudioObjectSystemObject)

    private var defaultOutputDevice: AudioDeviceID? {
        var device = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            systemObject,
            &address,
            0,
            nil,
            &size,
            &device
        )

        guard status == noErr else {
            return nil
        }

        return device
    }

    private let virtualMainVolume: AudioObjectPropertySelector = 0x766D_7663

    func getVolume() -> Float? {
        guard let device = defaultOutputDevice else {
            return nil
        }

        var volume: Float32 = 0

        var address = AudioObjectPropertyAddress(
            mSelector: virtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var size = UInt32(MemoryLayout<Float32>.size)

        let status = AudioObjectGetPropertyData(
            device,
            &address,
            0,
            nil,
            &size,
            &volume
        )

        guard status == noErr else {
            return nil
        }

        return volume
    }

    func setVolume(_ percentage: Float) -> Bool {
        guard let device = defaultOutputDevice else {
            return false
        }

        var volume = max(0, min(100, percentage)) / 100

        var address = AudioObjectPropertyAddress(
            mSelector: virtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let size = UInt32(MemoryLayout<Float32>.size)

        let status = AudioObjectSetPropertyData(
            device,
            &address,
            0,
            nil,
            size,
            &volume
        )
        return status == noErr
    }
}

let manager = VolumeManager()
let arguments = CommandLine.arguments

if arguments.count == 1 {
    if let volume = manager.getVolume() {
        print(Int(volume * 100))
    } else {
        exit(1)
    }
} else if arguments.count == 2,
    let percentage = Float(arguments[1])
{
    if manager.setVolume(percentage) {
        print(Int(percentage))
    } else {
        exit(1)
    }

} else {
    print("Usage:")
    print(" sketchybar-volume")
    print(" sketchybar-volume <percentage>")
    exit(1)
}
