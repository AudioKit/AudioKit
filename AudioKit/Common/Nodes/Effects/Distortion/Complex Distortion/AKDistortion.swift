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
public class AKDistortion: AKNode, AKToggleable {


    // MARK: - Properties

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Distortion,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    private var lastKnownMix: Double = 0.5

    /// Delay (Milliseconds) ranges from 0.1 to 500 (Default: 0.1)
    public var delay: Double = 0.1 {
        didSet {
            if delay < 0.1 {
                delay = 0.1
            }
            if delay > 500 {
                delay = 500
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Delay,
                kAudioUnitScope_Global, 0,
                Float(delay), 0)
        }
    }

    /// Decay (Rate) ranges from 0.1 to 50 (Default: 1.0)
    public var decay: Double = 1.0 {
        didSet {
            if decay < 0.1 {
                decay = 0.1
            }
            if decay > 50 {
                decay = 50
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_Decay,
                kAudioUnitScope_Global, 0,
                Float(decay), 0)
        }
    }

    /// Delay Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var delayMix: Double = 0.5 {
        didSet {
            if delayMix < 0 {
                delayMix = 0
            }
            if delayMix > 1 {
                delayMix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_DelayMix,
                kAudioUnitScope_Global, 0,
                Float(delayMix) * 100.0, 0)
        }
    }

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var decimation: Double = 0.5 {
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

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    public var rounding: Double = 0.0 {
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

    /// Decimation Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var decimationMix: Double = 0.5 {
        didSet {
            if decimationMix < 0 {
                decimationMix = 0
            }
            if decimationMix > 1 {
                decimationMix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_DecimationMix,
                kAudioUnitScope_Global, 0,
                Float(decimationMix) * 100.0, 0)
        }
    }

    /// Linear Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var linearTerm: Double = 0.5 {
        didSet {
            if linearTerm < 0 {
                linearTerm = 0
            }
            if linearTerm > 1 {
                linearTerm = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_LinearTerm,
                kAudioUnitScope_Global, 0,
                Float(linearTerm) * 100.0, 0)
        }
    }

    /// Squared Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var squaredTerm: Double = 0.5 {
        didSet {
            if squaredTerm < 0 {
                squaredTerm = 0
            }
            if squaredTerm > 1 {
                squaredTerm = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_SquaredTerm,
                kAudioUnitScope_Global, 0,
                Float(squaredTerm) * 100.0, 0)
        }
    }

    /// Cubic Term (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var cubicTerm: Double = 0.5 {
        didSet {
            if cubicTerm < 0 {
                cubicTerm = 0
            }
            if cubicTerm > 1 {
                cubicTerm = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_CubicTerm,
                kAudioUnitScope_Global, 0,
                Float(cubicTerm) * 100.0, 0)
        }
    }

    /// Polynomial Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var polynomialMix: Double = 0.5 {
        didSet {
            if polynomialMix < 0 {
                polynomialMix = 0
            }
            if polynomialMix > 1 {
                polynomialMix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_PolynomialMix,
                kAudioUnitScope_Global, 0,
                Float(polynomialMix * 100.0), 0)
        }
    }

    /// Ring Mod Freq1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var ringModFreq1: Double = 100 {
        didSet {
            if ringModFreq1 < 0.5 {
                ringModFreq1 = 0.5
            }
            if ringModFreq1 > 8000 {
                ringModFreq1 = 8000
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModFreq1,
                kAudioUnitScope_Global, 0,
                Float(ringModFreq1), 0)
        }
    }

    /// Ring Mod Freq2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var ringModFreq2: Double = 100 {
        didSet {
            if ringModFreq2 < 0.5 {
                ringModFreq2 = 0.5
            }
            if ringModFreq2 > 8000 {
                ringModFreq2 = 8000
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModFreq2,
                kAudioUnitScope_Global, 0,
                Float(ringModFreq2), 0)
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var ringModBalance: Double = 0.5 {
        didSet {
            if ringModBalance < 0 {
                ringModBalance = 0
            }
            if ringModBalance > 1 {
                ringModBalance = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModBalance,
                kAudioUnitScope_Global, 0,
                Float(ringModBalance * 100.0), 0)
        }
    }

    /// Ring Mod Mix (Normalized Value) ranges from 0 to 1 (Default: 0.0)
    public var ringModMix: Double = 0.0 {
        didSet {
            if ringModMix < 0 {
                ringModMix = 0
            }
            if ringModMix > 1 {
                ringModMix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_RingModMix,
                kAudioUnitScope_Global, 0,
                Float(ringModMix * 100.0), 0)
        }
    }

    /// Soft Clip Gain (dB) ranges from -80 to 20 (Default: -6)
    public var softClipGain: Double = -6 {
        didSet {
            if softClipGain < -80 {
                softClipGain = -80
            }
            if softClipGain > 20 {
                softClipGain = 20
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_SoftClipGain,
                kAudioUnitScope_Global, 0,
                Float(softClipGain), 0)
        }
    }

    /// Final Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var finalMix: Double = 0.5 {
        didSet {
            if finalMix < 0 {
                finalMix = 0
            }
            if finalMix > 1 {
                finalMix = 1
            }
            AudioUnitSetParameter(
                internalAU!,
                kDistortionParam_FinalMix,
                kAudioUnitScope_Global, 0,
                Float(finalMix * 100.0), 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
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
    public func start() {
        if isStopped {
            finalMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = finalMix
            finalMix = 0
            isStarted = false
        }
    }
}
