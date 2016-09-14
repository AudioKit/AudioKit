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
public class AKParametricEQ: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_ParametricEQ,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    private var mixer: AKMixer

    /// Center Freq (Hz) ranges from 20 to 22050 (Default: 2000)
    public var centerFrequency: Double = 2000 {
        didSet {
            if centerFrequency < 20 {
                centerFrequency = 20
            }
            if centerFrequency > 22050 {
                centerFrequency = 22050
            }
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_CenterFreq,
                kAudioUnitScope_Global, 0,
                Float(centerFrequency), 0)
        }
    }

    /// Q (Hz) ranges from 0.1 to 20 (Default: 1.0)
    public var q: Double = 1.0 {
        didSet {
            if q < 0.1 {
                q = 0.1
            }
            if q > 20 {
                q = 20
            }
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_Q,
                kAudioUnitScope_Global, 0,
                Float(q), 0)
        }
    }

    /// Gain (dB) ranges from -20 to 20 (Default: 0)
    public var gain: Double = 0 {
        didSet {
            if gain < -20 {
                gain = -20
            }
            if gain > 20 {
                gain = 20
            }
            AudioUnitSetParameter(
                internalAU!,
                kParametricEQParam_Gain,
                kAudioUnitScope_Global, 0,
                Float(gain), 0)
        }
    }

    /// Dry/Wet Mix (Default 100)
    public var dryWetMix: Double = 100 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()

            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kParametricEQParam_CenterFreq, kAudioUnitScope_Global, 0, Float(centerFrequency), 0)
            AudioUnitSetParameter(internalAU!, kParametricEQParam_Q, kAudioUnitScope_Global, 0, Float(q), 0)
            AudioUnitSetParameter(internalAU!, kParametricEQParam_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
