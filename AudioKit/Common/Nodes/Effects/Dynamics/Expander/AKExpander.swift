//
//  AKExpander.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// AudioKit Expander based on Apple's DynamicsProcessor Audio Unit
///
open class AKExpander: AKNode, AKToggleable, AUEffect, AKInput {

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper

    private var internalCompressionAmount: AudioUnitParameterValue = 0.0
    private var internalInputAmplitude: AudioUnitParameterValue = 0.0
    private var internalOutputAmplitude: AudioUnitParameterValue = 0.0

    /// Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    @objc open dynamic var expansionRatio: Double = 2 {
        didSet {
            expansionRatio = (1...50).clamp(expansionRatio)
            au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        }
    }

    /// Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    @objc open dynamic var expansionThreshold: Double = 2 {
        didSet {
            expansionThreshold = (1...50).clamp(expansionThreshold)
            au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        }
    }

    /// Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    @objc open dynamic var attackDuration: Double = 0.001 {
        didSet {
            attackDuration = (0.000_1...0.2).clamp(attackDuration)
            au[kDynamicsProcessorParam_AttackTime] = attackDuration
        }
    }

    /// Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    @objc open dynamic var releaseDuration: Double = 0.05 {
        didSet {
            releaseDuration = (0.01...3).clamp(releaseDuration)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        }
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    @objc open dynamic var masterGain: Double = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    /// Compression Amount (dB) read only
    @objc open dynamic var compressionAmount: Double {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    @objc open dynamic var inputAmplitude: Double {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    @objc open dynamic var outputAmplitude: Double {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    /// Dry/Wet Mix (Default 1)
    @objc open dynamic var dryWetMix: Double = 1 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            inputGain.volume = 1 - dryWetMix
            effectGain.volume = dryWetMix
        }
    }

    private var mixer = AKMixer()
    private var lastKnownMix: Double = 1
    private var inputMixer = AKMixer()
    private var inputGain = AKMixer()
    private var effectGain = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - attackDuration: Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseDuration: Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        threshold: Double = -20,
        headRoom: Double = 5,
        expansionRatio: Double = 2,
        expansionThreshold: Double = 2,
        attackDuration: Double = 0.001,
        releaseDuration: Double = 0.05,
        masterGain: Double = 0,
        compressionAmount: Double = 0,
        inputAmplitude: Double = 0,
        outputAmplitude: Double = 0) {

        self.expansionRatio = expansionRatio
        self.expansionThreshold = expansionThreshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.masterGain = masterGain

        inputGain.volume = 0
        effectGain.volume = 1

        input?.connect(to: inputMixer)
        inputMixer.connect(to: [inputGain, effectGain])

        let effect = _Self.effect
        self.internalEffect = effect
        AudioKit.engine.attach(effect)
        au = AUWrapper(effect)

        input?.connect(to: inputMixer)
        inputMixer >>> inputGain >>> mixer
        inputMixer >>> effectGain >>> effect >>> mixer

        super.init(avAudioNode: mixer.avAudioNode)

        au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        au[kDynamicsProcessorParam_AttackTime] = attackDuration
        au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        au[kDynamicsProcessorParam_MasterGain] = masterGain
    }

    public var inputNode: AVAudioNode {
        return inputMixer.avAudioNode
    }
    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }

    /// Disconnect the node
    open override func detach() {
        stop()

        AudioKit.detach(nodes: [inputGain.avAudioNode, effectGain.avAudioNode, mixer.avAudioNode])
        AudioKit.engine.detach(self.internalEffect)
    }
}
