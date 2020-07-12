// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    public typealias AKAudioUnitType = AKFormantFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Center frequency.
    @Parameter public var centerFrequency: AUValue

    /// Impulse response attack time (in seconds).
    @Parameter public var attackDuration: AUValue

    /// Impulse reponse decay time (in seconds)
    @Parameter public var decayDuration: AUValue

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
        centerFrequency: AUValue = 1_000,
        attackDuration: AUValue = 0.007,
        decayDuration: AUValue = 0.04
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
