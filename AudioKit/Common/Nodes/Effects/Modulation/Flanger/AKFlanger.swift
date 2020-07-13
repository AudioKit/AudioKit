// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Flanger
///
open class AKFlanger: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "flgr")

    public typealias AKAudioUnitType = AKFlangerAudioUnit

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

    /// Initialize this flanger node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix  - traditionally 50%, avoid changing this value
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = kAKFlanger_DefaultFrequency,
        depth: AUValue = kAKFlanger_DefaultDepth,
        feedback: AUValue = kAKFlanger_DefaultFeedback,
        dryWetMix: AUValue = kAKFlanger_DefaultDryWetMix
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
