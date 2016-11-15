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
/// - Parameters:
///   - input: Input node to process
///   - centerFrequency: Center Freq (Hz) ranges from 20 to 22050 (Default: 2000)
///   - q: Q (Hz) ranges from 0.1 to 20 (Default: 1.0)
///   - gain: Gain (dB) ranges from -20 to 20 (Default: 0)
///
open class AKParametricEQ: AKNode, AKToggleable, AUComponent {

    static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_ParametricEQ)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var mixer: AKMixer

    /// Center Freq (Hz) ranges from 20 to 22050 (Default: 2000)
    open var centerFrequency: Double = 2000 {
        didSet {
            centerFrequency = (20...22050).clamp(centerFrequency)
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_CenterFreq,
                kAudioUnitScope_Global, 0,
                Float(centerFrequency), 0)
        }
    }

    /// Q (Hz) ranges from 0.1 to 20 (Default: 1.0)
    open var q: Double = 1.0 {
        didSet {
            q = (0.1...20).clamp(q)
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_Q,
                kAudioUnitScope_Global, 0,
                Float(q), 0)
        }
    }

    /// Gain (dB) ranges from -20 to 20 (Default: 0)
    open var gain: Double = 0 {
        didSet {
            gain = (-20...20).clamp(gain)
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_Gain,
                kAudioUnitScope_Global, 0,
                Float(gain), 0)
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

    fileprivate var lastKnownMix: Double = 100
    fileprivate var inputGain: AKMixer?
    fileprivate var effectGain: AKMixer?

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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)
            super.init()

            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kParametricEQParam_CenterFreq, kAudioUnitScope_Global, 0, Float(centerFrequency), 0)
            AudioUnitSetParameter(internalAU!, kParametricEQParam_Q, kAudioUnitScope_Global, 0, Float(q), 0)
            AudioUnitSetParameter(internalAU!, kParametricEQParam_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
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
