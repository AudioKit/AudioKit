// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class DryWetMixer: Node {

    let input1: Node
    let input2: Node
    
    /// Connected nodes
    public var connections: [Node] { [input1, input2] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(mixer: "dwmx")

    // MARK: - Parameters

    /// Specification details for balance
    public static let balanceDef = NodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("DryWetMixerParameterBalance"),
        defaultValue: 0.5,
        range: 0.0...1.0,
        unit: .generic)

    /// Balance between input signals
    @Parameter(balanceDef) public var balance: AUValue

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    public init(_ input1: Node, _ input2: Node, balance: AUValue = balanceDef.defaultValue) {
        self.input1 = input1
        self.input2 = input2
        
        setupParameters()
        
        self.balance = balance
    }

    /// Initializer with dry wet labels
    /// - Parameters:
    ///   - dry: Input 1
    ///   - wet: Input 2
    ///   - balance: Balance between inputs
    public convenience init(dry: Node, wet: Node, balance: AUValue = 0.5) {
        self.init(dry, wet, balance: balance)
    }

}
