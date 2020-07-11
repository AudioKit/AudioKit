// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
open class AKDryWetMixer: AKNode, AKInput {
    fileprivate let mixer = AKMixer()

    /// Balance (Default 0.5)
    @objc open dynamic var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            setGainsViaBalance()
        }
    }

    fileprivate var input1Attenuator = AKMixer()
    fileprivate var input2Attenuator = AKMixer()

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    @objc public init(_ input1: AKNode? = nil, _ input2: AKNode? = nil, balance: Double = 0.5) {
        super.init(avAudioNode: AVAudioNode())
        avAudioNode = mixer.avAudioNode
        self.input1Attenuator.connect(to: mixer)
        self.input2Attenuator.connect(to: mixer)

        setGainsViaBalance()

        if let input1 = input1 {
            connectInput1(using: input1)
        }
        if let input2 = input2 {
            connectInput2(using: input2)
        }
        self.balance = balance
    }

    @objc public convenience init(dry: AKNode, wet: AKNode, balance: Double = 0.5) {
        self.init(dry, wet, balance: balance)
    }

    public var inputNode: AVAudioNode {
        return input1Attenuator.avAudioUnitOrNode
    }

    func connectInputs(input1: AKNode, input2: AKNode) {
        connectInput1(using: input1)
        connectInput2(using: input2)
    }

    func connectInput1(using node: AKNode) {
        node.connect(to: input1Attenuator)
    }

    func connectInput2(using node: AKNode) {
        node.connect(to: input2Attenuator)
    }

    private func setGainsViaBalance() {
        input1Attenuator.volume = AUValue(1 - balance)
        input2Attenuator.volume = AUValue(balance)
    }

    // Disconnect the node
    open override func detach() {
        AKManager.detach(nodes: [mixer.avAudioUnitOrNode,
                                input1Attenuator.avAudioUnitOrNode,
                                input2Attenuator.avAudioUnitOrNode])
    }

    open var dryInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: input1Attenuator.avAudioUnitOrNode, bus: 0)
    }

    open var wetInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: input2Attenuator.avAudioUnitOrNode, bus: 0)
    }

}
