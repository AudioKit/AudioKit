//
//  AKRingModulator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Ring Modulator from the Distortion Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - frequency1: Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
///   - frequency2: Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
///   - balance: Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
///
public class AKRingModulator: AKNode, AKToggleable {

    // MARK: - Properties

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Distortion,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    private var lastKnownMix: Double = 1

    /// Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var frequency1: Double = 100 {
        didSet {
            if frequency1 < 0.5 {
                frequency1 = 0.5
            }
            if frequency1 > 8000 {
                frequency1 = 8000
            }
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq1, kAudioUnitScope_Global, 0, Float(frequency1), 0)
        }
    }

    /// Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var frequency2: Double = 100 {
        didSet {
            if frequency2 < 0.5 {
                frequency2 = 0.5
            }
            if frequency2 > 8000 {
                frequency2 = 8000
            }
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq2, kAudioUnitScope_Global, 0, Float(frequency2), 0)
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var balance: Double = 0.5 {
        didSet {
            if balance < 0 {
                balance = 0
            }
            if balance > 1 {
                balance = 1
            }
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModBalance, kAudioUnitScope_Global, 0, Float(balance) * 100.0, 0)
        }
    }

    /// Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    public var mix: Double = 100 {
        didSet {
            if mix < 0 {
                mix = 0
            }
            if mix > 1 {
                mix = 1
            }
            AudioUnitSetParameter(internalAU!, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(mix) * 100.0, 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    // MARK: - Initialization

    /// Initialize the ring modulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency1: Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - frequency2: Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - balance: Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    ///
    public init(
        _ input: AKNode,
        frequency1: Double = 100,
        frequency2: Double = 100,
        balance: Double = 0.5,
        mix: Double = 1) {

            self.frequency1 = frequency1
            self.frequency2 = frequency2
            self.balance = balance
            self.mix = mix

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)

            super.init()
            avAudioNode = internalEffect
            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit

            // Since this is the Ring Modulator, mix it to 100% and use the final mix as the mix parameter
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModMix, kAudioUnitScope_Global, 0, 100, 0)

            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq1,   kAudioUnitScope_Global, 0, Float(frequency1), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModFreq2,   kAudioUnitScope_Global, 0, Float(frequency2), 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_RingModBalance, kAudioUnitScope_Global, 0, Float(balance) * 100.0, 0)
            AudioUnitSetParameter(internalAU!, kDistortionParam_FinalMix,       kAudioUnitScope_Global, 0, Float(mix) * 100.0, 0)

    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            mix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = mix
            mix = 0
            isStarted = false
        }
    }
}
