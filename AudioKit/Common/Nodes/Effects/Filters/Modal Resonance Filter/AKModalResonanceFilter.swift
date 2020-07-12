// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A modal resonance filter used for modal synthesis. Plucked and bell sounds
/// can be created using  passing an impulse through a combination of modal
/// filters.
///
open class AKModalResonanceFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "modf")

    public typealias AKAudioUnitType = AKModalResonanceFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Resonant frequency of the filter.
    @Parameter public var frequency: AUValue

    /// Quality factor of the filter. Roughly equal to Q/frequency.
    @Parameter public var qualityFactor: AUValue

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
        frequency: AUValue = 500.0,
        qualityFactor: AUValue = 50.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.qualityFactor = qualityFactor
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
