// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo Booster
///
public class AKBooster: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "bstr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    /// Amplification Factor
    open var gain: AUValue = 1 {
        didSet {
            leftGain = gain
            rightGain = gain
        }
    }

    public static let leftGainDef = AKNodeParameterDef(
        identifier: "leftGain",
        name: "Left Boosting Amount",
        address: akGetParameterAddress("AKBoosterParameterLeftGain"),
        range: 0.0...2.0,
        unit: .linearGain,
        flags: .default)

    /// Left Channel Amplification Factor
    @Parameter public var leftGain: AUValue

    public static let rightGainDef = AKNodeParameterDef(
        identifier: "rightGain",
        name: "Right Boosting Amount",
        address: akGetParameterAddress("AKBoosterParameterRightGain"),
        range: 0.0...2.0,
        unit: .linearGain,
        flags: .default)

    /// Right Channel Amplification Factor
    @Parameter public var rightGain: AUValue

    /// Amplification Factor in db
    open var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKBooster.leftGainDef,
             AKBooster.rightGainDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKBoosterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode, gain: AUValue = 1) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.leftGain = gain
            self.rightGain = gain
        }

        connections.append(input)
    }
}
