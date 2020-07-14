// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
    extension AKSettings {
        /// Global audio format AudioKit will default to for new objects and connections
        public static var audioFormat = defaultAudioFormat

        /// The hardware ioBufferDuration. Setting this will request the new value, getting
        /// will query the hardware.
        public static var ioBufferDuration: Double {
            set {
                let node = AKManager.engine.outputNode
                guard let audioUnit = node.audioUnit else { return }
                let samplerate = node.outputFormat(forBus: 0).sampleRate
                var frames = UInt32(round(newValue * samplerate))

                let status = AudioUnitSetProperty(audioUnit,
                                                  kAudioDevicePropertyBufferFrameSize,
                                                  kAudioUnitScope_Global,
                                                  0,
                                                  &frames,
                                                  UInt32(MemoryLayout<UInt32>.size))
                if status != 0 {
                    AKLog("error in set ioBufferDuration status \(status)", log: OSLog.settings, type: .error)
                }
            }
            get {
                let node = AKManager.engine.outputNode
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
                    AKLog("error in get ioBufferDuration status \(status)", log: OSLog.settings, type: .error)
                }
                return Double(frames) / sampleRate
            }
        }
    }

#endif
