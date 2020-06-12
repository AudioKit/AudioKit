// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's PeakLimiter Audio Unit
///
open class AKPeakLimiter: AKNode, AKToggleable, AUEffect, AKInput {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_PeakLimiter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Attack Duration (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    @objc open dynamic var attackDuration: AUValue = 0.012 {
        didSet {
            attackDuration = (0.001...0.03).clamp(attackDuration)
            au[kLimiterParam_AttackTime] = attackDuration
        }
    }

    /// Decay Duration (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    @objc open dynamic var decayDuration: AUValue = 0.024 {
        didSet {
            decayDuration = (0.001...0.06).clamp(decayDuration)
            au[kLimiterParam_DecayTime] = decayDuration
        }
    }

    /// Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    @objc open dynamic var preGain: AUValue = 0 {
        didSet {
            preGain = (-40...40).clamp(preGain)
            au[kLimiterParam_PreGain] = preGain
        }
    }

    /// Dry/Wet Mix (Default 1)
    @objc open dynamic var dryWetMix: AUValue = 1 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix
            effectGain?.volume = dryWetMix
        }
    }

    private var lastKnownMix: AUValue = 1
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?
    private var inputMixer = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize the peak limiter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack Duration (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    ///   - decayDuration: Decay Duration (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    ///   - preGain: Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        attackDuration: AUValue = 0.012,
        decayDuration: AUValue = 0.024,
        preGain: AUValue = 0) {
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.preGain = preGain

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

        au = AUWrapper(effect)

        super.init(avAudioNode: mixer.avAudioNode)
        AKManager.engine.attach(effect)

        if let node = effectGain?.avAudioNode {
            AKManager.engine.connect(node, to: effect, format: AKSettings.audioFormat)
        }
        AKManager.engine.connect(effect, to: mixer.avAudioNode, format: AKSettings.audioFormat)

        au[kLimiterParam_AttackTime] = attackDuration
        au[kLimiterParam_DecayTime] = decayDuration
        au[kLimiterParam_PreGain] = preGain
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
