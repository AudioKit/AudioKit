//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Audio from the standard input
open class AKMicrophone: AKNode, AKToggleable {

    internal let mixer = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixer.outputVolume = Float(volume)
        }
    }

    /// Set the actual microphone device
    public func setDevice(_ device: AKDevice) throws {
        do {
            try AudioKit.setInputDevice(device)
        } catch {
            AKLog("Could not set input device")
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the microphone is currently on.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
    override public init() {
        super.init()
        self.avAudioNode = mixer
        AKSettings.audioInputEnabled = true

        #if os(iOS)
        let format = getFormatForDevice()
        // we have to connect the input at the original device sample rate, because once AVAudioEngine is initialized, it reports the wrong rate
        setAVSessionSampleRate(sampleRate: AudioKit.deviceSampleRate)
        AudioKit.engine.attach(avAudioUnitOrNode)
        AudioKit.engine.connect(AudioKit.engine.inputNode, to: self.avAudioNode, format: format!)
        setAVSessionSampleRate(sampleRate: AKSettings.sampleRate)
        #elseif !os(tvOS)
        AudioKit.engine.inputNode.connect(to: self.avAudioNode)
        #endif
    }

    deinit {
        AKSettings.audioInputEnabled = false
    }

    private func setAVSessionSampleRate(sampleRate: Double) {
        #if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setPreferredSampleRate(sampleRate)
        } catch {
            AKLog(error)
        }
        #endif
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    // Here is where we actually check the device type and make the settings, if needed
    private func getFormatForDevice() -> AVAudioFormat? {
        var channelCount: UInt32 = 2
        #if os(iOS) && !targetEnvironment(simulator)
        channelCount = AudioKit.engine.inputNode.inputFormat(forBus: 0).channelCount
        let desiredFS = AudioKit.deviceSampleRate
        #else
        let desiredFS = AKSettings.sampleRate
        #endif
        return AVAudioFormat(standardFormatWithSampleRate: desiredFS, channels: channelCount)
    }
}
