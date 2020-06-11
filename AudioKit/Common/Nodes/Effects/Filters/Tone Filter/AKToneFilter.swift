// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A first-order recursive low-pass filter with variable frequency response.
///
open class AKToneFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tone")

    public typealias AKAudioUnitType = AKToneFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Half Power Point
    public static let halfPowerPointRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Initial value for Half Power Point
    public static let defaultHalfPowerPoint: AUValue = 1_000.0

    /// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    public let halfPowerPoint = AKNodeParameter(identifier: "halfPowerPoint")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    ///
    public init(
        _ input: AKNode? = nil,
        halfPowerPoint: AUValue = defaultHalfPowerPoint
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.halfPowerPoint.associate(with: self.internalAU, value: halfPowerPoint)

            input?.connect(to: self)
        }
    }
}
