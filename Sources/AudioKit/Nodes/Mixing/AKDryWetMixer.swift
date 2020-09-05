// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
public class AKDryWetMixer: AKNode, AKToggleable, AKComponent {

   public static let ComponentDescription = AudioComponentDescription(effect: "dwmx")

   public typealias AKAudioUnitType = InternalAU

   public private(set) var internalAU: AKAudioUnitType?

   // MARK: - Parameters

    public static let balanceDef = AKNodeParameterDef(
        identifier: "balance",
        name: "Balance",
        address: akGetParameterAddress("AKDryWetMixerParameterBalance"),
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Balance between input signals
    @Parameter public var balance: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKDryWetMixer.balanceDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKDryWetMixerDSP")
        }
    }

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - input1: 1st source
    ///   - input2: 2nd source
    ///   - balance: Balance Point (0 = all input1, 1 = all input2)
    ///
    public init(_ input1: AKNode, _ input2: AKNode, balance: AUValue = 0.5) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.balance = balance
        }

        connections.append(input1)
        connections.append(input2)
    }

    public convenience init(dry: AKNode, wet: AKNode, balance: AUValue = 0.5) {
        self.init(dry, wet, balance: balance)
    }

}
