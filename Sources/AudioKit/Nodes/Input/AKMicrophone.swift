// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Audio from the standard input
public class AKMicrophone: AKNode, AKToggleable {
    internal let mixer = AVAudioMixerNode()
    internal let engine: AVAudioEngine

    /// Output Volume (Default 1)
    public var volume: AUValue = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixer.outputVolume = volume
        }
    }

    /// Set the actual microphone device
    public func setDevice(_ device: AKDevice) throws {
        do {
            try AKEngine.setInputDevice(device)
        } catch {
            AKLog("Could not set input device")
        }
    }

    fileprivate var lastKnownVolume: AUValue = 1.0

    /// Determine if the microphone is currently on.
    public var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
    public init?(engine: AVAudioEngine, with format: AVAudioFormat? = nil) {
        self.engine = engine
        super.init(avAudioNode: mixer)

        guard let formatForDevice = getFormatForDevice() else {
            AKLog("Error! Cannot unwrap format for device. Can't init the mic.")
            return nil
        }
        AKSettings.audioInputEnabled = true

        #if os(iOS)
        engine.attach(avAudioUnitOrNode)
        engine.connect(engine.inputNode, to: avAudioNode, format: format ?? formatForDevice)
        #elseif !os(tvOS)
        // AKLog("avAudioNode.outputFormat(forBus: 0)", avAudioNode.outputFormat(forBus: 0))
        // NOTE: format is ignored on macOS here. AKMicrophone for macOS is partially functional
//        engine.inputNode.connect(to: avAudioNode)
        #endif
    }

    // Making this throw as whenever we have sample rate mismatches, it often crashes.
    private func setAVSessionSampleRate(sampleRate: Double) throws {
        #if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setPreferredSampleRate(sampleRate)
        } catch {
            AKLog(error.localizedDescription)
            throw error
        }
        #endif
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    // Here is where we actually check the device type and make the settings, if needed
    private func getFormatForDevice() -> AVAudioFormat? {
        let audioFormat: AVAudioFormat?

        var currentFormat = AKSettings.audioFormat
        var sampleRate = AKSettings.sampleRate

        #if os(iOS) && !targetEnvironment(simulator)
        sampleRate = AVAudioSession.sharedInstance().sampleRate
        currentFormat = engine.inputNode.inputFormat(forBus: 0)
        #elseif os(macOS)
        sampleRate = engine.inputNode.outputFormat(forBus: 0).sampleRate
        currentFormat = engine.inputNode.inputFormat(forBus: 0)
        #endif

        if let layout = currentFormat.channelLayout {
            audioFormat = AVAudioFormat(commonFormat: currentFormat.commonFormat,
                                        sampleRate: sampleRate,
                                        interleaved: currentFormat.isInterleaved,
                                        channelLayout: layout)
        } else {
            audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        }

        return audioFormat
    }
}
