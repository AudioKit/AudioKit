// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's DynamicsProcessor Audio Unit
///
open class AKDynamicsProcessor: AKNode, AKToggleable, AUEffect, AKInput {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper
    fileprivate var mixer: AKMixer

    /// Threshold (dB) ranges from -100 to 20 (Default: -20)
    @objc open dynamic var threshold: AUValue = -20 {
        didSet {
            threshold = (-100...20).clamp(threshold)
            au[kDynamicsProcessorParam_Threshold] = threshold
        }
    }

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    @objc open dynamic var headRoom: AUValue = 5 {
        didSet {
            headRoom = (0.1...40).clamp(headRoom)
            au[kDynamicsProcessorParam_HeadRoom] = headRoom
        }
    }

    /// Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    @objc open dynamic var expansionRatio: AUValue = 2 {
        didSet {
            expansionRatio = (1...50).clamp(expansionRatio)
            au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        }
    }

    /// Expansion Threshold (rate) ranges from -120 to 0 (Default: 0)
    @objc open dynamic var expansionThreshold: AUValue = 0 {
        didSet {
            expansionThreshold = (-120...0).clamp(expansionThreshold)
            au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        }
    }

    /// Attack Duration (secs) ranges from 0.001 to 0.3 (Default: 0.001)
    @objc open dynamic var attackDuration: AUValue = 0.001 {
        didSet {
            attackDuration = (0.001...0.3).clamp(attackDuration)
            au[kDynamicsProcessorParam_AttackTime] = attackDuration
        }
    }

    /// Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    @objc open dynamic var releaseDuration: AUValue = 0.05 {
        didSet {
            releaseDuration = (0.01...3).clamp(releaseDuration)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        }
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    @objc open dynamic var masterGain: AUValue = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    /// Compression Amount (dB) read only
    @objc open dynamic var compressionAmount: AUValue {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    @objc open dynamic var inputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    @objc open dynamic var outputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    /// Dry/Wet Mix (Default 1 Fully Wet)
    @objc open dynamic var dryWetMix: AUValue = 1 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix
            effectGain?.volume = dryWetMix
        }
    }

    fileprivate var lastKnownMix: AUValue = 1
    fileprivate var inputGain: AKMixer?
    fileprivate var effectGain: AKMixer?
    fileprivate var inputMixer = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    ///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    ///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - attackDuration: Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseDuration: Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///   - compressionAmount: Compression Amount (dB) ranges from -40 to 40 (Default: 0)
    ///   - inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///   - outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        threshold: AUValue = -20,
        headRoom: AUValue = 5,
        expansionRatio: AUValue = 2,
        expansionThreshold: AUValue = 2,
        attackDuration: AUValue = 0.001,
        releaseDuration: AUValue = 0.05,
        masterGain: AUValue = 0,
        compressionAmount: AUValue = 0,
        inputAmplitude: AUValue = 0,
        outputAmplitude: AUValue = 0) {
        self.threshold = threshold
        self.headRoom = headRoom
        self.expansionRatio = expansionRatio
        self.expansionThreshold = expansionThreshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.masterGain = masterGain

        inputGain = AKMixer()
        inputGain?.volume = 0
        mixer = AKMixer(inputGain)

        effectGain = AKMixer()
        effectGain?.volume = 1

        input?.connect(to: inputMixer)
        if let inputGain = inputGain,
            let effectGain = effectGain {
            inputMixer.connect(to: [inputGain, effectGain])
        }
        let effect = _Self.effect
        internalEffect = effect

        AKManager.engine.attach(effect)

        au = AUWrapper(effect)

        if let node = effectGain?.avAudioNode {
            AKManager.engine.connect(node, to: effect)
        }
        AKManager.engine.connect(effect, to: mixer.avAudioNode)

        super.init(avAudioNode: mixer.avAudioNode)

        au[kDynamicsProcessorParam_Threshold] = threshold
        au[kDynamicsProcessorParam_HeadRoom] = headRoom
        au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        au[kDynamicsProcessorParam_AttackTime] = attackDuration
        au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        au[kDynamicsProcessorParam_MasterGain] = masterGain
    }

    public var inputNode: AVAudioNode {
        return inputMixer.avAudioNode
    }

    // MARK: - Control

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

        var nodes: [AVAudioNode] = [inputMixer.avAudioNode,
                                    mixer.avAudioNode,
                                    internalEffect]

        if let inputGain = inputGain {
            nodes.append(inputGain.avAudioNode)
        }

        if let effectGain = effectGain {
            nodes.append(effectGain.avAudioNode)
        }

        AKManager.detach(nodes: nodes)
    }
}
