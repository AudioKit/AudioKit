// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class AKDryWetMixer: AKNode {
    fileprivate let mixer = AKMixer()

    /// Balance (Default 0.5)
    public var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            setGainsViaBalance()
        }
    }

    fileprivate var input1Attenuator = AKBooster()
    fileprivate var input2Attenuator = AKBooster()

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    public init(_ input1: AKNode, _ input2: AKNode, balance: Double = 0.5) {
        super.init(avAudioNode: AVAudioNode())
        self.balance = balance
        setGainsViaBalance()

        avAudioNode = mixer.avAudioNode
        input1 >>> input1Attenuator
        input2 >>> input2Attenuator

        connections.append(input1Attenuator)
        connections.append(input2Attenuator)

        self.balance = balance
        setGainsViaBalance()


    }

    public convenience init(dry: AKNode, wet: AKNode, balance: Double = 0.5) {
        self.init(dry, wet, balance: balance)
    }

    private func setGainsViaBalance() {
        input1Attenuator.gain = AUValue(1 - balance)
        input2Attenuator.gain = AUValue(balance)
    }

    open var dryInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: input1Attenuator.avAudioUnitOrNode, bus: 0)
    }

    open var wetInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: input2Attenuator.avAudioUnitOrNode, bus: 0)
    }

}
