//
//  AKCompressor.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit Compressor based on Apple's DynamicsProcessor Audio Unit
///
open class AKCompressor: AKNode, AKToggleable, AUEffect {
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper

    fileprivate var mixer: AKMixer

    /// Threshold (dB) ranges from -40 to 20 (Default: -20)
    open dynamic var threshold: Double = -20 {
        didSet {
            threshold = (-40...20).clamp(threshold)
            au[kDynamicsProcessorParam_Threshold] = threshold
        }
    }

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    open dynamic var headRoom: Double = 5 {
        didSet {
            headRoom = (0.1...40).clamp(headRoom)
            au[kDynamicsProcessorParam_HeadRoom] = headRoom
        }
    }

    /// Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    open dynamic var attackTime: Double = 0.001 {
        didSet {
            attackTime = (0.000_1...0.2).clamp(attackTime)
            au[kDynamicsProcessorParam_AttackTime] = attackTime
        }
    }

    /// Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    open dynamic var releaseTime: Double = 0.05 {
        didSet {
            releaseTime = (0.01...3).clamp(releaseTime)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseTime
        }
    }

    /// Compression Amount (dB) read only
    open dynamic var compressionAmount: Double {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    open dynamic var inputAmplitude: Double {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    open dynamic var outputAmplitude: Double {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    open dynamic var masterGain: Double = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    /// Dry/Wet Mix (Default 100)
    open dynamic var dryWetMix: Double = 100 {
        didSet {
            dryWetMix = (0...100).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    fileprivate var lastKnownMix: Double = 100
    fileprivate var inputGain: AKMixer? 
    fileprivate var effectGain: AKMixer?
    
    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    ///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    ///   - attackTime: Attack Time (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseTime: Release Time (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode?,
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
            inputGain?.volume = 0
            mixer = AKMixer(inputGain)

            effectGain = AKMixer(input)
            effectGain?.volume = 1

            let effect = _Self.effect
            self.internalEffect = effect
        
            AudioKit.engine.attach(effect)
            au = AUWrapper(effect)
            if let node = effectGain?.avAudioNode {
                AudioKit.engine.connect(node, to: effect)
            }
            AudioKit.engine.connect(effect, to: mixer.avAudioNode)
        
            super.init(avAudioNode: mixer.avAudioNode)

            au[kDynamicsProcessorParam_Threshold] = threshold
            au[kDynamicsProcessorParam_HeadRoom] = headRoom
            au[kDynamicsProcessorParam_AttackTime] = attackTime
            au[kDynamicsProcessorParam_ReleaseTime] = releaseTime
            au[kDynamicsProcessorParam_MasterGain] = masterGain
    }

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
    
    /// Disconnect the node
    override open func disconnect() {
        stop()
        
        disconnect(nodes: [inputGain!.avAudioNode, effectGain!.avAudioNode, mixer.avAudioNode])
        AudioKit.engine.detach(self.internalEffect)
    }
}
