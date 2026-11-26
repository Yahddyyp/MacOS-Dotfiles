import CoreAudio
import Foundation

final class VolumeManager {
    private let systemObject = AudioObjectID(kAudioObjectSystemObject)
    // 'vmvc' (kAudioHardwareServiceDeviceProperty_VirtualMainVolume)
    private let virtualMainVolume: AudioObjectPropertySelector = 0x766D_7663

    private var defaultOutputDevice: AudioDeviceID? {
        var device = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(systemObject, &address, 0, nil, &size, &device)
        guard status == noErr, device != kAudioObjectUnknown else { return nil }
        return device
    }

    private func volumeAddress(for device: AudioDeviceID) -> AudioObjectPropertyAddress? {
        let candidates: [(AudioObjectPropertySelector, AudioObjectPropertyElement)] = [
            (virtualMainVolume, kAudioObjectPropertyElementMain),
            (kAudioDevicePropertyVolumeScalar, kAudioObjectPropertyElementMain),
            (kAudioDevicePropertyVolumeScalar, 1) // Left channel fallback for stereo DACs
        ]

        for (selector, element) in candidates {
            var address = AudioObjectPropertyAddress(
                mSelector: selector,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: element
            )
            if AudioObjectHasProperty(device, &address) {
                return address
            }
        }
        return nil
    }

    func getVolume() -> Int? {
        guard let device = defaultOutputDevice, var address = volumeAddress(for: device) else {
            return nil
        }

        var volume: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)
        let status = AudioObjectGetPropertyData(device, &address, 0, nil, &size, &volume)
        guard status == noErr else { return nil }

        return Int((volume * 100).rounded())
    }

    func setVolume(_ percentage: Float) -> Int? {
        guard percentage.isFinite,
              let device = defaultOutputDevice,
              var address = volumeAddress(for: device) else {
            return nil
        }

        var settable: DarwinBoolean = false
        guard AudioObjectIsPropertySettable(device, &address, &settable) == noErr,
              settable.boolValue else {
            return nil
        }

        let clamped = max(0, min(100, percentage))
        var scalar = clamped / 100
        let size = UInt32(MemoryLayout<Float32>.size)
        let status = AudioObjectSetPropertyData(device, &address, 0, nil, size, &scalar)
        guard status == noErr else { return nil }

        // If setting stereo channel 1 fallback, mirror to channel 2 if present
        if address.mSelector == kAudioDevicePropertyVolumeScalar, address.mElement == 1 {
            var rightAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: 2
            )
            if AudioObjectHasProperty(device, &rightAddress) {
                _ = AudioObjectSetPropertyData(device, &rightAddress, 0, nil, size, &scalar)
            }
        }

        return Int(clamped.rounded())
    }
}

let manager = VolumeManager()
let arguments = CommandLine.arguments

if arguments.count == 1 {
    if let volume = manager.getVolume() {
        print(volume)
    } else {
        exit(1)
    }
} else if arguments.count == 2, let percentage = Float(arguments[1]) {
    if let applied = manager.setVolume(percentage) {
        print(applied)
    } else {
        exit(1)
    }
} else {
    fputs("Usage: sketchybar-volume [percentage]\n", stderr)
    exit(1)
}
