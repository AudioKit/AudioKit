// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// A complement to the AKLowPassFilter.
///
public class AKToneComplementFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "aton")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let halfPowerPointDef = AKNodeParameterDef(
        identifier: "halfPowerPoint",
        name: "Half-Power Point (Hz)",
        address: akGetParameterAddress("AKToneComplementFilterParameterHalfPowerPoint"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    @Parameter public var halfPowerPoint: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKToneComplementFilter.halfPowerPointDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKToneComplementFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///
    public init(
        _ input: AKNode? = nil,
        halfPowerPoint: AUValue = 1_000.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.halfPowerPoint = halfPowerPoint
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }
}
