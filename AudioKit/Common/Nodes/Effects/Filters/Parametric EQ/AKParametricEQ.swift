//
//  AKParametricEQ.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's ParametricEQ Audio Unit
///
open class AKParametricEQ: AKNode, AKToggleable, AUEffect {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_ParametricEQ)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Center Freq (Hz) ranges from 20 to 22050 (Default: 2000)
    open var centerFrequency: Double = 2000 {
        didSet {
            centerFrequency = (20...22050).clamp(centerFrequency)
            au[kParametricEQParam_CenterFreq] = centerFrequency
        }
    }

    /// Q (Hz) ranges from 0.1 to 20 (Default: 1.0)
    open var q: Double = 1.0 {
        didSet {
            q = (0.1...20).clamp(q)
            au[kParametricEQParam_Q] = q
        }
    }

    /// Gain (dB) ranges from -20 to 20 (Default: 0)
    open var gain: Double = 0 {
        didSet {
            gain = (-20...20).clamp(gain)
            au[kParametricEQParam_Gain] = gain
        }
    }

    /// Dry/Wet Mix (Default 100)
    open var dryWetMix: Double = 100 {
        didSet {
            dryWetMix = (0...100).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    // MARK: - Initialization

    /// Initialize the parametric eq node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center Frequency (Hz) ranges from 20 to 22050 (Default: 2000)
    ///   - q: Q (Hz) ranges from 0.1 to 20 (Default: 1.0)
    ///   - gain: Gain (dB) ranges from -20 to 20 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 2000,
        q: Double = 1.0,
        gain: Double = 0) {
            self.centerFrequency = centerFrequency
            self.q = q
            self.gain = gain

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)
            effectGain = AKMixer(input)
            effectGain!.volume = 1
            let effect = _Self.effect
            au = AUWrapper(au: effect)
            super.init(avAudioNode: mixer.avAudioNode)

            AudioKit.engine.attach(effect)
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: effect)
            AudioKit.engine.connect(effect, to: mixer.avAudioNode)

            au[kParametricEQParam_CenterFreq] = centerFrequency
            au[kParametricEQParam_Q] = q
            au[kParametricEQParam_Gain] = gain
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
}
