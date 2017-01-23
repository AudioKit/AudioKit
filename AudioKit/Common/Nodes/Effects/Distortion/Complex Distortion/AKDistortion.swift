//
//  AKDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Distortion Audio Unit
///
open class AKDistortion: AKNode, AKToggleable, AUEffect {

    // MARK: - Properties

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)

    private var au: AUWrapper
    private var lastKnownMix: Double = 0.5

    /// Delay (Milliseconds) ranges from 0.1 to 500 (Default: 0.1)
    open var delay: Double = 0.1 {
        didSet {
            delay = (0.1...500).clamp(delay)
            au[kDistortionParam_Delay] = delay
        }
    }

    /// Decay (Rate) ranges from 0.1 to 50 (Default: 1.0)
    open var decay: Double = 1.0 {
        didSet {
            decay = (0.1...50).clamp(decay)
            au[kDistortionParam_Decay] = decay
        }
    }

    /// Delay Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var delayMix: Double = 0.5 {
        didSet {
            delayMix = (0...1).clamp(delayMix)
            au[kDistortionParam_DelayMix] = delayMix * 100
        }
    }

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var decimation: Double = 0.5 {
        didSet {
            decimation = (0...1).clamp(decimation)
            au[kDistortionParam_Decimation] = decimation * 100
        }
    }

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    open var rounding: Double = 0.0 {
        didSet {
            rounding = (0...1).clamp(rounding)
            au[kDistortionParam_Rounding] = rounding * 100
        }
    }

    /// Decimation Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var decimationMix: Double = 0.5 {
        didSet {
            decimationMix = (0...1).clamp(decimationMix)
            au[kDistortionParam_DecimationMix] = decimationMix * 100
        }
    }

    /// Linear Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var linearTerm: Double = 0.5 {
        didSet {
            linearTerm = (0...1).clamp(linearTerm)
            au[kDistortionParam_LinearTerm] = linearTerm * 100
        }
    }

    /// Squared Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var squaredTerm: Double = 0.5 {
        didSet {
            squaredTerm = (0...1).clamp(squaredTerm)
            au[kDistortionParam_SquaredTerm] = squaredTerm * 100
        }
    }

    /// Cubic Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var cubicTerm: Double = 0.5 {
        didSet {
            cubicTerm = (0...1).clamp(cubicTerm)
            au[kDistortionParam_CubicTerm] = cubicTerm * 100
        }
    }

    /// Polynomial Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var polynomialMix: Double = 0.5 {
        didSet {
            polynomialMix = (0...1).clamp(polynomialMix)
            au[kDistortionParam_PolynomialMix] = polynomialMix * 100
        }
    }

    /// Ring Mod Freq1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    open var ringModFreq1: Double = 100 {
        didSet {
            ringModFreq1 = (0.5...8000).clamp(ringModFreq1)
            au[kDistortionParam_RingModFreq1] = ringModFreq1
        }
    }

    /// Ring Mod Freq2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    open var ringModFreq2: Double = 100 {
        didSet {
            ringModFreq2 = (0.5...8000).clamp(ringModFreq2)
            au[kDistortionParam_RingModFreq2] = ringModFreq2
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var ringModBalance: Double = 0.5 {
        didSet {
            ringModBalance = (0...1).clamp(ringModBalance)
            au[kDistortionParam_RingModBalance] = ringModBalance * 100
        }
    }

    /// Ring Mod Mix (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    open var ringModMix: Double = 0.0 {
        didSet {
            ringModMix = (0...1).clamp(ringModMix)
            au[kDistortionParam_RingModMix] = ringModMix * 100
        }
    }

    /// Soft Clip Gain (dB) ranges from -80 to 20 (Default: -6)
    open var softClipGain: Double = -6 {
        didSet {
            softClipGain = (-80...20).clamp(softClipGain)
            au[kDistortionParam_SoftClipGain] = softClipGain
        }
    }

    /// Final Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var finalMix: Double = 0.5 {
        didSet {
            finalMix = (0...1).clamp(finalMix)
            au[kDistortionParam_FinalMix] = finalMix * 100
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

            let effect = _Self.effect
            au = AUWrapper(au: effect)

            super.init(avAudioNode: effect, attach: true)

            input.addConnectionPoint(self)

            au[kDistortionParam_Delay] = delay
            au[kDistortionParam_Decay] = decay
            au[kDistortionParam_DelayMix] = delayMix * 100
            au[kDistortionParam_Decimation] = decimation * 100
            au[kDistortionParam_Rounding] = rounding * 100
            au[kDistortionParam_DecimationMix] = decimationMix * 100
            au[kDistortionParam_LinearTerm] = linearTerm * 100
            au[kDistortionParam_SquaredTerm] = squaredTerm * 100
            au[kDistortionParam_CubicTerm] = cubicTerm * 100
            au[kDistortionParam_PolynomialMix] = polynomialMix * 100
            au[kDistortionParam_RingModFreq1] = ringModFreq1
            au[kDistortionParam_RingModFreq2] = ringModFreq2
            au[kDistortionParam_RingModBalance] = ringModBalance * 100
            au[kDistortionParam_RingModMix] = ringModMix * 100
            au[kDistortionParam_SoftClipGain] = softClipGain
            au[kDistortionParam_FinalMix] = finalMix * 100
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
