// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Shane's Chorus
///
open class AKChorus: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    public typealias AKAudioUnitType = AKChorusAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Modulation Frequency (Hz)
    @Parameter public var frequency: AUValue

    /// Modulation Depth (fraction)
    @Parameter public var depth: AUValue

    /// Feedback (fraction)
    @Parameter public var feedback: AUValue

    /// Dry Wet Mix (fraction)
    @Parameter public var dryWetMix: AUValue

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency. (in Hertz)
    ///   - depth: Depth
    ///   - feedback: Feedback
    ///   - dryWetMix: Dry Wet Mix
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = 1,
        depth: AUValue = 0,
        feedback: AUValue = 0,
        dryWetMix: AUValue = 0
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.depth = depth
        self.feedback = feedback
        self.dryWetMix = dryWetMix

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
