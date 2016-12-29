//
//  AKDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Distortion Audio Unit
///
open class AKDistortion: AKNode, AKToggleable, AUComponent {

    // MARK: - Properties

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var lastKnownMix: Double = 0.5

    /// Delay (Milliseconds) ranges from 0.1 to 500 (Default: 0.1)
    open var delay: Double = 0.1 {
        didSet {
            delay = (0.1...500).clamp(delay)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Delay,
                kAudioUnitScope_Global, 0,
                Float(delay), 0)
        }
    }

    /// Decay (Rate) ranges from 0.1 to 50 (Default: 1.0)
    open var decay: Double = 1.0 {
        didSet {
            decay = (0.1...50).clamp(decay)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Decay,
                kAudioUnitScope_Global, 0,
                Float(decay), 0)
        }
    }

    /// Delay Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var delayMix: Double = 0.5 {
        didSet {
            delayMix = (0...1).clamp(delayMix)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_DelayMix,
                kAudioUnitScope_Global, 0,
                Float(delayMix) * 100.0, 0)
        }
    }

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var decimation: Double = 0.5 {
        didSet {
            decimation = (0...1).clamp(decimation)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Decimation,
                kAudioUnitScope_Global, 0,
                Float(decimation) * 100.0, 0)
        }
    }

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    open var rounding: Double = 0.0 {
        didSet {
            rounding = (0...1).clamp(rounding)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Rounding,
                kAudioUnitScope_Global, 0,
                Float(rounding) * 100.0, 0)
        }
    }

    /// Decimation Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var decimationMix: Double = 0.5 {
        didSet {
            decimationMix = (0...1).clamp(decimationMix)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_DecimationMix,
                kAudioUnitScope_Global, 0,
                Float(decimationMix) * 100.0, 0)
        }
    }

    /// Linear Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var linearTerm: Double = 0.5 {
        didSet {
            linearTerm = (0...1).clamp(linearTerm)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_LinearTerm,
                kAudioUnitScope_Global, 0,
                Float(linearTerm) * 100.0, 0)
        }
    }

    /// Squared Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var squaredTerm: Double = 0.5 {
        didSet {
            squaredTerm = (0...1).clamp(squaredTerm)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_SquaredTerm,
                kAudioUnitScope_Global, 0,
                Float(squaredTerm) * 100.0, 0)
        }
    }

    /// Cubic Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var cubicTerm: Double = 0.5 {
        didSet {
            cubicTerm = (0...1).clamp(cubicTerm)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_CubicTerm,
                kAudioUnitScope_Global, 0,
                Float(cubicTerm) * 100.0, 0)
        }
    }

    /// Polynomial Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var polynomialMix: Double = 0.5 {
        didSet {
            polynomialMix = (0...1).clamp(polynomialMix)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_PolynomialMix,
                kAudioUnitScope_Global, 0,
                Float(polynomialMix * 100.0), 0)
        }
    }

    /// Ring Mod Freq1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    open var ringModFreq1: Double = 100 {
        didSet {
            ringModFreq1 = (0.5...8000).clamp(ringModFreq1)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModFreq1,
                kAudioUnitScope_Global, 0,
                Float(ringModFreq1), 0)
        }
    }

    /// Ring Mod Freq2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    open var ringModFreq2: Double = 100 {
        didSet {
            ringModFreq2 = (0.5...8000).clamp(ringModFreq2)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModFreq2,
                kAudioUnitScope_Global, 0,
                Float(ringModFreq2), 0)
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var ringModBalance: Double = 0.5 {
        didSet {
            ringModBalance = (0...1).clamp(ringModBalance)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModBalance,
                kAudioUnitScope_Global, 0,
                Float(ringModBalance * 100.0), 0)
        }
    }

    /// Ring Mod Mix (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    open var ringModMix: Double = 0.0 {
        didSet {
            ringModMix = (0...1).clamp(ringModMix)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModMix,
                kAudioUnitScope_Global, 0,
                Float(ringModMix * 100.0), 0)
        }
    }

    /// Soft Clip Gain (dB) ranges from -80 to 20 (Default: -6)
    open var softClipGain: Double = -6 {
        didSet {
            softClipGain = (-80...20).clamp(softClipGain)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_SoftClipGain,
                kAudioUnitScope_Global, 0,
                Float(softClipGain), 0)
        }
    }

    /// Final Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var finalMix: Double = 0.5 {
        didSet {
            finalMix = (0...1).clamp(finalMix)
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_FinalMix,
                kAudioUnitScope_Global, 0,
                Float(finalMix * 100.0), 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    // MARK: - Initialization

    /// Initialize the distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - delay: Delay (Milliseconds) ranges from 0.1 to 500 (Default: 0.1)
    ///   - decay: Decay (Rate) ranges from 0.1 to 50 (Default: 1.0)
    ///   - delayMix: Delay Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - decimation: Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - rounding: Rounding (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    ///   - decimationMix: Decimation Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - linearTerm: Linear Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - squaredTerm: Squared Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - cubicTerm: Cubic Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - polynomialMix: Polynomial Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - ringModFreq1: Ring Mod Freq1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - ringModFreq2: Ring Mod Freq2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - ringModBalance: Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - ringModMix: Ring Mod Mix (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    ///   - softClipGain: Soft Clip Gain (dB) ranges from -80 to 20 (Default: -6)
    ///   - finalMix: Final Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///
    public init(
        _ input: AKNode,
        delay: Double = 0.1,
        decay: Double = 1.0,
        delayMix: Double = 0.5,
        decimation: Double = 0.5,
        rounding: Double = 0.0,
        decimationMix: Double = 0.5,
        linearTerm: Double = 0.5,
        squaredTerm: Double = 0.5,
        cubicTerm: Double = 0.5,
        polynomialMix: Double = 0.5,
        ringModFreq1: Double = 100,
        ringModFreq2: Double = 100,
        ringModBalance: Double = 0.5,
        ringModMix: Double = 0.0,
        softClipGain: Double = -6,
        finalMix: Double = 0.5) {

            self.delay = delay
            self.decay = decay
            self.delayMix = delayMix
            self.decimation = decimation
            self.rounding = rounding
            self.decimationMix = decimationMix
            self.linearTerm = linearTerm
            self.squaredTerm = squaredTerm
            self.cubicTerm = cubicTerm
            self.polynomialMix = polynomialMix
            self.ringModFreq1 = ringModFreq1
            self.ringModFreq2 = ringModFreq2
            self.ringModBalance = ringModBalance
            self.ringModMix = ringModMix
            self.softClipGain = softClipGain
            self.finalMix = finalMix
            internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)

            super.init()
            avAudioNode = internalEffect
            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit

            AudioUnitSetParameter(internalAU!, kDistortionParam_Delay, kAudioUnitScope_Global, 0, Float(delay), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_Decay, kAudioUnitScope_Global, 0, Float(decay), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_DelayMix, kAudioUnitScope_Global, 0, Float(delayMix) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_Decimation, kAudioUnitScope_Global, 0, Float(decimation) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_Rounding, kAudioUnitScope_Global, 0, Float(rounding) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_DecimationMix, kAudioUnitScope_Global, 0, Float(decimationMix) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_LinearTerm, kAudioUnitScope_Global, 0, Float(linearTerm) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_SquaredTerm, kAudioUnitScope_Global, 0, Float(squaredTerm) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_CubicTerm, kAudioUnitScope_Global, 0, Float(cubicTerm) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_PolynomialMix, kAudioUnitScope_Global, 0, Float(polynomialMix) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq1, kAudioUnitScope_Global, 0, Float(ringModFreq1), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq2, kAudioUnitScope_Global, 0, Float(ringModFreq2), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModBalance, kAudioUnitScope_Global, 0, Float(ringModBalance) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModMix, kAudioUnitScope_Global, 0, Float(ringModMix) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_SoftClipGain, kAudioUnitScope_Global, 0, Float(softClipGain), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(finalMix) * 100.0, 0)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            finalMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = finalMix
            finalMix = 0
            isStarted = false
        }
    }
}
