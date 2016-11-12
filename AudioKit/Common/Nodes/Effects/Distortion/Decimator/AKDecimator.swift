//
//  AKDecimator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Decimator from the Distortion Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - decimation: Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
///   - rounding: Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
///
open class AKDecimator: AKNode, AKToggleable {

    // MARK: - Properties

    fileprivate let cd = AudioComponentDescription(effect: kAudioUnitSubType_Distortion)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var lastKnownMix: Double = 1

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var decimation: Double = 0.5 {
        didSet {
            if decimation < 0 {
                decimation = 0
            }
            if decimation > 1 {
                decimation = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Decimation,
                kAudioUnitScope_Global, 0,
                Float(decimation) * 100.0, 0)
        }
    }

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
    open var rounding: Double = 0 {
        didSet {
            if rounding < 0 {
                rounding = 0
            }
            if rounding > 1 {
                rounding = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Rounding,
                kAudioUnitScope_Global, 0,
                Float(rounding) * 100.0, 0)
        }
    }

    /// Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    open var mix: Double = 1 {
        didSet {
            if mix < 0 {
                mix = 0
            }
            if mix > 1 {
                mix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_FinalMix,
                kAudioUnitScope_Global, 0,
                Float(mix) * 100.0, 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    // MARK: - Initialization

    /// Initialize the decimator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - decimation: Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - rounding: Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
    ///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    ///
    public init(
        _ input: AKNode,
        decimation: Double = 0.5,
        rounding: Double = 0,
        mix: Double = 1) {

            self.decimation = decimation
            self.rounding = rounding
            self.mix = mix

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()

            avAudioNode = internalEffect
            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit

            // Since this is the Decimator, mix it to 100% and use the final mix as the mix parameter
            AudioUnitSetParameter(internalAU!, kDistortionParam_DecimationMix, kAudioUnitScope_Global, 0, 100, 0)

            AudioUnitSetParameter(internalAU!, kDistortionParam_Decimation, kAudioUnitScope_Global, 0, Float(decimation) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_Rounding, kAudioUnitScope_Global, 0, Float(rounding) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(mix) * 100.0, 0)
            //turn off the other distortion effects
            AudioUnitSetParameter(internalAU!, kDistortionParam_PolynomialMix, kAudioUnitScope_Global, 0, 0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModMix, kAudioUnitScope_Global, 0, 0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_DelayMix, kAudioUnitScope_Global, 0, 0, 0)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            mix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = mix
            mix = 0
            isStarted = false
        }
    }
}
