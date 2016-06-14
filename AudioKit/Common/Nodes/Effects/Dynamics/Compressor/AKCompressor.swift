//
//  AKCompressor.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/18/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation

/// AudioKit Compressor based on Apple's DynamicsProcessor Audio Unit
///
/// - parameter input: Input node to process
/// - parameter threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
/// - parameter headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
/// - parameter attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
/// - parameter releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
/// - parameter masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
/// - parameter compressionAmount: Compression Amount (dB) ranges from -40 to 40 (Default: 0) (read only)
/// - parameter inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (Default: 0) (read only)
/// - parameter outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (Default: 0) (read only)
///
public class AKCompressor: AKNode, AKToggleable {
    
    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_DynamicsProcessor,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)
    
    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil
    
    private var mixer: AKMixer
    
    private var internalCompressionAmount:AudioUnitParameterValue = 0.0
    private var internalInputAmplitude:AudioUnitParameterValue = 0.0
    private var internalOutputAmplitude:AudioUnitParameterValue = 0.0
    
    /// Threshold (dB) ranges from -40 to 20 (Default: -20)
    public var threshold: Double = -20 {
        didSet {
            if threshold < -40 {
                threshold = -40
            }
            if threshold > 20 {
                threshold = 20
            }
            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_Threshold,
                kAudioUnitScope_Global, 0,
                Float(threshold), 0)
        }
    }
    
    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    public var headRoom: Double = 5 {
        didSet {
            if headRoom < 0.1 {
                headRoom = 0.1
            }
            if headRoom > 40.0 {
                headRoom = 40.0
            }
            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_HeadRoom,
                kAudioUnitScope_Global, 0,
                Float(headRoom), 0)
        }
    }
    
    /// Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    public var attackTime: Double = 0.001 {
        didSet {
            if attackTime < 0.0001 {
                attackTime = 0.0001
            }
            if attackTime > 0.2 {
                attackTime = 0.2
            }
            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_AttackTime,
                kAudioUnitScope_Global, 0,
                Float(attackTime), 0)
        }
    }
    
    /// Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    public var releaseTime: Double = 0.05 {
        didSet {
            if releaseTime < 0.01 {
                releaseTime = 0.01
            }
            if releaseTime > 3 {
                releaseTime = 3
            }
            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_ReleaseTime,
                kAudioUnitScope_Global, 0,
                Float(releaseTime), 0)
        }
    }
    
    /// Compression Amount (dB) read only
    public var compressionAmount: Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalCompressionAmount)
        return Double(internalCompressionAmount)
    }
    
    /// Input Amplitude (dB) read only
    public var inputAmplitude:Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalInputAmplitude)
        return Double(internalInputAmplitude)
    }
    
    /// Output Amplitude (dB) read only
    public var outputAmplitude: Double {
        AudioUnitGetParameter(internalAU!, kDynamicsProcessorParam_CompressionAmount, kAudioUnitScope_Global, 0,&internalOutputAmplitude)
        return Double(internalOutputAmplitude)
    }
    
    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    public var masterGain: Double = 0 {
        didSet {
            if masterGain < -40 {
                masterGain = -40
            }
            if masterGain > 40 {
                masterGain = 40
            }
            AudioUnitSetParameter(
                internalAU!,
                kDynamicsProcessorParam_MasterGain,
                kAudioUnitScope_Global, 0,
                Float(masterGain), 0)
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
    
    /// Initialize the dynamics processor node
    ///
    /// - parameter input: Input node to process
    /// - parameter threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    /// - parameter headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    /// - parameter attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    /// - parameter releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    /// - parameter masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    /// - parameter compressionAmount: Compression Amount (dB) ranges from -40 to 40 (read only)
    /// - parameter inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (read only)
    /// - parameter outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (read only)
    ///
    public init(
        _ input: AKNode,
        threshold: Double = -20,
        headRoom: Double = 5,
        attackTime: Double = 0.001,
        releaseTime: Double = 0.05,
        masterGain: Double = 0) {
            
            self.threshold = threshold
            self.headRoom = headRoom
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
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_AttackTime, kAudioUnitScope_Global, 0, Float(attackTime), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_ReleaseTime, kAudioUnitScope_Global, 0, Float(releaseTime), 0)
            AudioUnitSetParameter(internalAU!, kDynamicsProcessorParam_MasterGain, kAudioUnitScope_Global, 0, Float(masterGain), 0)
    }
    
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
