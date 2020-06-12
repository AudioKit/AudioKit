// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's HighShelfFilter Audio Unit
///
open class AKHighShelfFilter: AKNode, AKToggleable, AUEffect, AKInput {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighShelfFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    @objc open dynamic var cutoffFrequency: AUValue = 10_000 {
        didSet {
            cutoffFrequency = (10_000...22_050).clamp(cutoffFrequency)
            au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    @objc open dynamic var gain: AUValue = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kHighShelfParam_Gain] = gain
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

    // MARK: - Initialization

    /// Initialize the high shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutOffFrequency: Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutOffFrequency: AUValue = 10_000,
        gain: AUValue = 0) {
        cutoffFrequency = cutOffFrequency
        self.gain = gain

        inputGain = AKMixer()
        inputGain?.volume = 0
        mixer = AKMixer(inputGain)

        effectGain = AKMixer()
        effectGain?.volume = 1

        input?.connect(to: inputMixer)

        // Even grosser looking than force unwrap, but...
        if let inputGain = self.inputGain,
            let effectGain = self.effectGain {
            inputMixer.connect(to: [inputGain, effectGain])
        }

        let effect = _Self.effect
        internalEffect = effect

        au = AUWrapper(effect)
        super.init(avAudioNode: mixer.avAudioNode)

        AKManager.engine.attach(effect)
        if let node = effectGain?.avAudioNode {
            AKManager.engine.connect(node, to: effect)
        }
        AKManager.engine.connect(effect, to: mixer.avAudioNode)

        au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
        au[kHighShelfParam_Gain] = gain
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
        guard let inputGain = inputGain, let effectGain = effectGain else { return }

        AKManager.detach(nodes: [inputMixer.avAudioNode,
                                 inputGain.avAudioNode,
                                 effectGain.avAudioNode,
                                 mixer.avAudioNode])
        AKManager.engine.detach(internalEffect)
    }
}
