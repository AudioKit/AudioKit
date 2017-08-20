//
//  AKLowShelfFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's LowShelfFilter Audio Unit
///
open class AKLowShelfFilter: AKNode, AKToggleable, AUEffect {

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowShelfFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    open dynamic var cutoffFrequency: Double = 80 {
        didSet {
            cutoffFrequency = (10...200).clamp(cutoffFrequency)
            au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    open dynamic var gain: Double = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kAULowShelfParam_Gain] = gain
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

    // MARK: - Initialization

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted = true

    /// Initialize the low shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode?,
        cutoffFrequency: Double = 80,
        gain: Double = 0) {

        self.cutoffFrequency = cutoffFrequency
        self.gain = gain

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

        au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        au[kAULowShelfParam_Gain] = gain
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
