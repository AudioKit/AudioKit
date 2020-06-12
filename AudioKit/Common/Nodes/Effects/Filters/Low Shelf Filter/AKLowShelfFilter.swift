// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's LowShelfFilter Audio Unit
///
open class AKLowShelfFilter: AKNode, AKToggleable, AUEffect, AKInput {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowShelfFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    @objc open dynamic var cutoffFrequency: AUValue = 80 {
        didSet {
            cutoffFrequency = (10...200).clamp(cutoffFrequency)
            au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    @objc open dynamic var gain: AUValue = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kAULowShelfParam_Gain] = gain
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
    var inputMixer = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    // MARK: - Initialization

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize the low shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 80,
        gain: AUValue = 0) {
        self.cutoffFrequency = cutoffFrequency
        self.gain = gain

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
            AKManager.engine.connect(node, to: effect)
        }
        AKManager.engine.connect(effect, to: mixer.avAudioNode)

        au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        au[kAULowShelfParam_Gain] = gain
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
