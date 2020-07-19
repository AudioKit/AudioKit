// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A first-order recursive low-pass filter with variable frequency response.
///
public class AKToneFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "tone")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    static let halfPowerPointDef = AKNodeParameterDef(
        identifier: "halfPowerPoint",
        name: "Half-Power Point (Hz)",
        address: AKToneFilterParameter.halfPowerPoint.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    @Parameter public var halfPowerPoint: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKToneFilter.halfPowerPointDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createToneFilterDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
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

            input?.connect(to: self)
        }
    }
}
