// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
import Foundation
import CoreAudio

struct AudioDeviceUtils {

    static func devices() -> [AudioDeviceID] {
        var propsize: UInt32 = 0

        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var result = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject),
                                                    &address,
                                                    UInt32(MemoryLayout<AudioObjectPropertyAddress>.size),
                                                    nil, &propsize)

        if result != 0 {
            AKLog("Error \(result) from AudioObjectGetPropertyDataSize")
            return []
        }

        let numDevices = Int(propsize / UInt32(MemoryLayout<AudioDeviceID>.size))

        if numDevices == 0 {
            return []
        }

        var devids = [AudioDeviceID](repeating: 0, count: numDevices)

        result = 0
        devids.withUnsafeMutableBufferPointer { bufferPointer in
            if let pointer = bufferPointer.baseAddress {
                result = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                                    &address,
                                                    0,
                                                    nil,
                                                    &propsize,
                                                    pointer)
            }
        }

        if result != 0 {
            AKLog("Error \(result) from AudioObjectGetPropertyData")
            return []
        }

        return devids
    }

    static func name(_ device: AudioDeviceID) -> String {

        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var name: CFString?
        var propsize: UInt32 = UInt32(MemoryLayout<CFString?>.size)
        let result: OSStatus = AudioObjectGetPropertyData(device, &address, 0, nil, &propsize, &name)
        if result != 0 {
            return ""
        }

        if let str = name {
            return str as String
        }

        return ""

    }

    static func outputChannels(_ device: AudioDeviceID) -> Int {

        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreamConfiguration),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: 0)

        var propsize: UInt32 = 0
        var result: OSStatus = AudioObjectGetPropertyDataSize(device, &address, 0, nil, &propsize)
        if result != 0 {
            return 0
        }

        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propsize))
        result = AudioObjectGetPropertyData(device, &address, 0, nil, &propsize, bufferList)
        if result != 0 {
            return 0
        }

        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        var channels = 0
        for i in 0..<buffers.count {
            channels += Int(buffers[i].mNumberChannels)
        }

        return channels

    }

    static func inputChannels(_ device: AudioDeviceID) -> Int {

        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreamConfiguration),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeInput),
            mElement: 0)

        var propsize: UInt32 = 0
        var result: OSStatus = AudioObjectGetPropertyDataSize(device, &address, 0, nil, &propsize)
        if result != 0 {
            return 0
        }

        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propsize))
        result = AudioObjectGetPropertyData(device, &address, 0, nil, &propsize, bufferList)
        if result != 0 {
            return 0
        }

        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        var channels = 0
        for i in 0..<buffers.count {
            channels += Int(buffers[i].mNumberChannels)
        }

        return channels

    }

    static func uid(_ device: AudioDeviceID) -> String {

        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceUID),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var name: CFString?
        var propsize: UInt32 = UInt32(MemoryLayout<CFString?>.size)
        let result: OSStatus = AudioObjectGetPropertyData(device, &address, 0, nil, &propsize, &name)
        if result != 0 {
            return ""
        }

        if let str = name {
            return str as String
        }

        return ""
    }

}
#endif
