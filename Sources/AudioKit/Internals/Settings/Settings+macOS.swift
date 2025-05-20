// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)

import AVFoundation
import os.log

extension Settings {
    /// Global audio format AudioKit will default to for new objects and connections
    /// - Tag: SettingsAudioFormat
    public static var audioFormat = defaultAudioFormat

    /// The hardware ioBufferDuration. Setting this will request the new value, getting
    /// will query the hardware.
    public static func getIOBufferDuration(engine: AVAudioEngine) -> Double {
        let node = engine.outputNode
        guard let audioUnit = node.audioUnit else { return 0 }
        let sampleRate = node.outputFormat(forBus: 0).sampleRate
        var frames = UInt32()
        var propSize = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioUnitGetProperty(audioUnit,
                                          kAudioDevicePropertyBufferFrameSize,
                                          kAudioUnitScope_Global,
                                          0,
                                          &frames,
                                          &propSize)
        if status != 0 {
            Log("error in get ioBufferDuration status \(status)", log: OSLog.settings, type: .error)
        }
        return Double(frames) / sampleRate
    }
}

#endif
