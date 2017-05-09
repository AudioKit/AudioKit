//
//  AKLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's LowPassFilter Audio Unit
///
open class AKLowPassFilter: AKNode, AKToggleable, AUEffect {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowPassFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    open dynamic var cutoffFrequency: Double = 6_900 {
        didSet {
            cutoffFrequency = (10...22_050).clamp(cutoffFrequency)
            au[kLowPassParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Resonance (dB) ranges from -20 to 40 (Default: 0)
    open dynamic var resonance: Double = 0 {
        didSet {
            resonance = (-20...40).clamp(resonance)
            au[kLowPassParam_Resonance] = resonance
        }
    }

    /// Dry/Wet Mix (Default 100)
    open dynamic var dryWetMix: Double = 100 {
        didSet {
            dryWetMix = (0...100).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?
    
    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted = true

    // MARK: - Initialization

    /// Initialize the low pass filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    ///   - resonance: Resonance (dB) ranges from -20 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode?,
        cutoffFrequency: Double = 6_900,
        resonance: Double = 0) {

            self.cutoffFrequency = cutoffFrequency
            self.resonance = resonance

            inputGain = AKMixer(input)
            inputGain?.volume = 0
            mixer = AKMixer(inputGain)

            effectGain = AKMixer(input)
            effectGain?.volume = 1

            let effect = _Self.effect
            self.internalEffect = effect
        
            au = AUWrapper(effect)

            super.init(avAudioNode: mixer.avAudioNode)

            AudioKit.engine.attach(effect)
            if let node = effectGain?.avAudioNode {
                AudioKit.engine.connect(node, to: effect)
            }
            AudioKit.engine.connect(effect, to: mixer.avAudioNode)

            au[kLowPassParam_Resonance] = resonance
            au[kLowPassParam_CutoffFrequency] = cutoffFrequency
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
    
    /// Disconnect the node
    override open func disconnect() {
        stop()
        
        disconnect(nodes: [inputGain!.avAudioNode, effectGain!.avAudioNode, mixer.avAudioNode])
        AudioKit.engine.detach(self.internalEffect)
    }
}
