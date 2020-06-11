// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    public typealias AKAudioUnitType = AKFormantFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange: ClosedRange<AUValue> = 0.0 ... 0.1

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<AUValue> = 0.0 ... 0.1

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: AUValue = 1_000

    /// Initial value for Attack Duration
    public static let defaultAttackDuration: AUValue = 0.007

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: AUValue = 0.04

    /// Center frequency.
    public let centerFrequency = AKNodeParameter(identifier: "centerFrequency")

    /// Impulse response attack time (in seconds).
    public let attackDuration = AKNodeParameter(identifier: "attackDuration")

    /// Impulse reponse decay time (in seconds)
    public let decayDuration = AKNodeParameter(identifier: "decayDuration")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - attackDuration: Impulse response attack time (in seconds).
    ///   - decayDuration: Impulse reponse decay time (in seconds)
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = defaultCenterFrequency,
        attackDuration: AUValue = defaultAttackDuration,
        decayDuration: AUValue = defaultDecayDuration
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.centerFrequency.associate(with: self.internalAU, value: centerFrequency)
            self.attackDuration.associate(with: self.internalAU, value: attackDuration)
            self.decayDuration.associate(with: self.internalAU, value: decayDuration)

            input?.connect(to: self)
        }
    }
}
