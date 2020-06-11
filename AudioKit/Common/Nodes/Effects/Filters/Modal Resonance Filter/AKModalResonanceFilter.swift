// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A modal resonance filter used for modal synthesis. Plucked and bell sounds
/// can be created using  passing an impulse through a combination of modal
/// filters.
///
open class AKModalResonanceFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "modf")

    public typealias AKAudioUnitType = AKModalResonanceFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Quality Factor
    public static let qualityFactorRange: ClosedRange<AUValue> = 0.0 ... 100.0

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 500.0

    /// Initial value for Quality Factor
    public static let defaultQualityFactor: AUValue = 50.0

    /// Resonant frequency of the filter.
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Quality factor of the filter. Roughly equal to Q/frequency.
    public let qualityFactor = AKNodeParameter(identifier: "qualityFactor")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Resonant frequency of the filter.
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = defaultFrequency,
        qualityFactor: AUValue = defaultQualityFactor
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.qualityFactor.associate(with: self.internalAU, value: qualityFactor)

            input?.connect(to: self)
        }
    }
}
