// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class DryWetMixer: Node, AudioUnitContainer, Toggleable {

   public static let ComponentDescription = AudioComponentDescription(effect: "dwmx")

   public typealias AudioUnitType = InternalAU

   public private(set) var internalAU: AudioUnitType?

   // MARK: - Parameters

    public static let balanceDef = NodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("DryWetMixerParameterBalance"),
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Balance between input signals
    @Parameter public var balance: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {

        public override func getParameterDefs() -> [NodeParameterDef] {
            [DryWetMixer.balanceDef]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("DryWetMixerDSP")
        }
    }

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    public init(_ input1: Node, _ input2: Node, balance: AUValue = 0.5) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.balance = balance
        }

        connections.append(input1)
        connections.append(input2)
    }

    public convenience init(dry: Node, wet: Node, balance: AUValue = 0.5) {
        self.init(dry, wet, balance: balance)
    }

}
