//
//  AKDynamicsProcessor.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's DynamicsProcessor Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
///   - attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
///   - releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
///   - compressionAmount: Compression Amount (dB) ranges from -40 to 40 (Default: 0) (read only)
///   - inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (Default: 0) (read only)
///   - outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (Default: 0) (read only)
///
open class AKDynamicsProcessor: AKNode, AKToggleable {

    fileprivate let cd = AudioComponentDescription(effect: kAudioUnitSubType_DynamicsProcessor)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var mixer: AKMixer

    fileprivate var internalCompressionAmount:AudioUnitParameterValue = 0.0
    fileprivate var internalInputAmplitude:AudioUnitParameterValue = 0.0
    fileprivate var internalOutputAmplitude:AudioUnitParameterValue = 0.0

    /// Threshold (dB) ranges from -40 to 20 (Default: -20)
    open var threshold: Double = -20 {
        didSet {
            threshold = (-40...20).clamp(threshold)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_Threshold,
                kAudioUnitScope_Global, 0,
                Float(threshold), 0)
        }
    }

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    open var headRoom: Double = 5 {
        didSet {
            headRoom = (0.1...40).clamp(headRoom)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_HeadRoom,
                kAudioUnitScope_Global, 0,
                Float(headRoom), 0)
        }
    }

    /// Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    open var expansionRatio: Double = 2 {
        didSet {
            expansionRatio = (1...50).clamp(expansionRatio)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_ExpansionRatio,
                kAudioUnitScope_Global, 0,
                Float(expansionRatio), 0)
        }
    }

    /// Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    open var expansionThreshold: Double = 2 {
        didSet {
            expansionThreshold = (1...50).clamp(expansionThreshold)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_ExpansionThreshold,
                kAudioUnitScope_Global, 0,
                Float(expansionThreshold), 0)
        }
    }

    /// Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    open var attackTime: Double = 0.001 {
        didSet {
            attackTime = (0.0001...0.2).clamp(attackTime)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_AttackTime,
                kAudioUnitScope_Global, 0,
                Float(attackTime), 0)
        }
    }

    /// Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    open var releaseTime: Double = 0.05 {
        didSet {
            releaseTime = (0.01...3).clamp(releaseTime)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_ReleaseTime,
                kAudioUnitScope_Global, 0,
                Float(releaseTime), 0)
        }
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    open var masterGain: Double = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)

            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_MasterGain,
                kAudioUnitScope_Global, 0,
                Float(masterGain), 0)
        }
    }

    /// Compression Amount (dB) read only
    open var compressionAmount: Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalCompressionAmount)
        return Double(internalCompressionAmount)
    }

    /// Input Amplitude (dB) read only
    open var inputAmplitude:Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalInputAmplitude)
        return Double(internalInputAmplitude)
    }

    /// Output Amplitude (dB) read only
    open var outputAmplitude: Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalOutputAmplitude)
        return Double(internalOutputAmplitude)
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

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    ///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    ///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///   - compressionAmount: Compression Amount (dB) ranges from -40 to 40 (Default: 0)
    ///   - inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///   - outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        threshold: Double = -20,
        headRoom: Double = 5,
        expansionRatio: Double = 2,
        expansionThreshold: Double = 2,
        attackTime: Double = 0.001,
        releaseTime: Double = 0.05,
        masterGain: Double = 0,
        compressionAmount: Double = 0,
        inputAmplitude: Double = 0,
        outputAmplitude: Double = 0) {

            self.threshold = threshold
            self.headRoom = headRoom
            self.expansionRatio = expansionRatio
            self.expansionThreshold = expansionThreshold
            self.attackTime = attackTime
            self.releaseTime = releaseTime
            self.masterGain = masterGain

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)

            effectGain = AKMixer(input)
            effectGain!.volume = 1

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)

            super.init()
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, Float(threshold), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_HeadRoom, kAudioUnitScope_Global, 0, Float(headRoom), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_ExpansionRatio, kAudioUnitScope_Global, 0, Float(expansionRatio), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_ExpansionThreshold, kAudioUnitScope_Global, 0, Float(expansionThreshold), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_AttackTime, kAudioUnitScope_Global, 0, Float(attackTime), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_ReleaseTime, kAudioUnitScope_Global, 0, Float(releaseTime), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_MasterGain, kAudioUnitScope_Global, 0, Float(masterGain), 0)
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
