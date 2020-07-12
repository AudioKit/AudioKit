// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A first-order recursive low-pass filter with variable frequency response.
///
open class AKToneFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "tone")

    public typealias AKAudioUnitType = AKToneFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    @Parameter public var halfPowerPoint: AUValue

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
