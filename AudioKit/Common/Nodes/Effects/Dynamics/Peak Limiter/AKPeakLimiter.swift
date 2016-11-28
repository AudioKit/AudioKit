//
//  AKPeakLimiter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's PeakLimiter Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - attackTime: Attack Time (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
///   - decayTime: Decay Time (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
///   - preGain: Pre Gain (dB) ranges from -40 to 40 (Default: 0)
///
open class AKPeakLimiter: AKNode, AKToggleable, AUComponent {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_PeakLimiter)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var mixer: AKMixer

    /// Attack Time (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    open var attackTime: Double = 0.012 {
        didSet {
            attackTime = (0.001...0.03).clamp(attackTime)
            AudioUnitSetParameter(
                internalAU!,
                kLimiterParam_AttackTime,
                kAudioUnitScope_Global, 0,
                Float(attackTime), 0)
        }
    }

    /// Decay Time (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    open var decayTime: Double = 0.024 {
        didSet {
            decayTime = (0.001...0.06).clamp(decayTime)
            AudioUnitSetParameter(
                internalAU!,
                kLimiterParam_DecayTime,
                kAudioUnitScope_Global, 0,
                Float(decayTime), 0)
        }
    }

    /// Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    open var preGain: Double = 0 {
        didSet {
            preGain = (-40...40).clamp(preGain)
            AudioUnitSetParameter(
                internalAU!,
                kLimiterParam_PreGain,
                kAudioUnitScope_Global, 0,
                Float(preGain), 0)
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

    /// Initialize the peak limiter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackTime: Attack Time (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    ///   - decayTime: Decay Time (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    ///   - preGain: Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        attackTime: Double = 0.012,
        decayTime: Double = 0.024,
        preGain: Double = 0) {

            self.attackTime = attackTime
            self.decayTime = decayTime
            self.preGain = preGain

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)

            effectGain = AKMixer(input)
            effectGain!.volume = 1

            internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)
            super.init()
            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            self.avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kLimiterParam_AttackTime, kAudioUnitScope_Global, 0, Float(attackTime), 0)
            AudioUnitSetParameter(internalAU!, kLimiterParam_DecayTime, kAudioUnitScope_Global, 0, Float(decayTime), 0)
            AudioUnitSetParameter(internalAU!, kLimiterParam_PreGain, kAudioUnitScope_Global, 0, Float(preGain), 0)
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
