// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class DryWetMixer: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "dwmx"
   public static let ComponentDescription = AudioComponentDescription(mixer: "dwmx")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    let input1: Node
    let input2: Node
    override public var connections: [Node] { [input1, input2] }

    // MARK: - Parameters

    /// Specification details for balance
    public static let balanceDef = NodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("DryWetMixerParameterBalance"),
        defaultValue: 0.5,
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

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
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.balance = balance
        }
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
