// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Shane's Chorus
///
public class AKChorus: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKModulatedDelayParameter.frequency.rawValue,
        range: 0.1 ... 10.0,
        unit: .hertz,
        flags: .default)

    /// Modulation Frequency (Hz)
    @Parameter public var frequency: AUValue

    public static let depthDef = AKNodeParameterDef(
        identifier: "depth",
        name: "Depth 0-1",
        address: AKModulatedDelayParameter.depth.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Modulation Depth (fraction)
    @Parameter public var depth: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback 0-1",
        address: AKModulatedDelayParameter.feedback.rawValue,
        range: 0.0 ... 0.25,
        unit: .generic,
        flags: .default)

    /// Feedback (fraction)
    @Parameter public var feedback: AUValue

    public static let dryWetMixDef = AKNodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry Wet Mix 0-1",
        address: AKModulatedDelayParameter.dryWetMix.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Dry Wet Mix (fraction)
    @Parameter public var dryWetMix: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKChorus.frequencyDef,
                    AKChorus.depthDef,
                    AKChorus.feedbackDef,
                    AKChorus.dryWetMixDef]
        }

        public override func createDSP() -> AKDSPRef {
            return akChorusCreateDSP()
        }
    }

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
