// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
public class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    static let notchMinimumFrequencyDef = AKNodeParameterDef(
        identifier: "notchMinimumFrequency",
        name: "Notch Minimum Frequency",
        address: AKPhaserParameter.notchMinimumFrequency.rawValue,
        range: 20 ... 5_000,
        unit: .hertz,
        flags: .default)

    /// Notch Minimum Frequency
    @Parameter public var notchMinimumFrequency: AUValue

    static let notchMaximumFrequencyDef = AKNodeParameterDef(
        identifier: "notchMaximumFrequency",
        name: "Notch Maximum Frequency",
        address: AKPhaserParameter.notchMaximumFrequency.rawValue,
        range: 20 ... 10_000,
        unit: .hertz,
        flags: .default)

    /// Notch Maximum Frequency
    @Parameter public var notchMaximumFrequency: AUValue

    static let notchWidthDef = AKNodeParameterDef(
        identifier: "notchWidth",
        name: "Between 10 and 5000",
        address: AKPhaserParameter.notchWidth.rawValue,
        range: 10 ... 5_000,
        unit: .hertz,
        flags: .default)

    /// Between 10 and 5000
    @Parameter public var notchWidth: AUValue

    static let notchFrequencyDef = AKNodeParameterDef(
        identifier: "notchFrequency",
        name: "Between 1.1 and 4",
        address: AKPhaserParameter.notchFrequency.rawValue,
        range: 1.1 ... 4.0,
        unit: .hertz,
        flags: .default)

    /// Between 1.1 and 4
    @Parameter public var notchFrequency: AUValue

    static let vibratoModeDef = AKNodeParameterDef(
        identifier: "vibratoMode",
        name: "Direct or Vibrato (default)",
        address: AKPhaserParameter.vibratoMode.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Direct or Vibrato (default)
    @Parameter public var vibratoMode: AUValue

    static let depthDef = AKNodeParameterDef(
        identifier: "depth",
        name: "Between 0 and 1",
        address: AKPhaserParameter.depth.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Between 0 and 1
    @Parameter public var depth: AUValue

    static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Between 0 and 1",
        address: AKPhaserParameter.feedback.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Between 0 and 1
    @Parameter public var feedback: AUValue

    static let invertedDef = AKNodeParameterDef(
        identifier: "inverted",
        name: "1 or 0",
        address: AKPhaserParameter.inverted.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// 1 or 0
    @Parameter public var inverted: AUValue

    static let lfoBPMDef = AKNodeParameterDef(
        identifier: "lfoBPM",
        name: "Between 24 and 360",
        address: AKPhaserParameter.lfoBPM.rawValue,
        range: 24 ... 360,
        unit: .generic,
        flags: .default)

    /// Between 24 and 360
    @Parameter public var lfoBPM: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKPhaser.notchMinimumFrequencyDef,
                    AKPhaser.notchMaximumFrequencyDef,
                    AKPhaser.notchWidthDef,
                    AKPhaser.notchFrequencyDef,
                    AKPhaser.vibratoModeDef,
                    AKPhaser.depthDef,
                    AKPhaser.feedbackDef,
                    AKPhaser.invertedDef,
                    AKPhaser.lfoBPMDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createPhaserDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this phaser node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - notchMinimumFrequency: Notch Minimum Frequency
    ///   - notchMaximumFrequency: Notch Maximum Frequency
    ///   - notchWidth: Between 10 and 5000
    ///   - notchFrequency: Between 1.1 and 4
    ///   - vibratoMode: Direct or Vibrato (default)
    ///   - depth: Between 0 and 1
    ///   - feedback: Between 0 and 1
    ///   - inverted: 1 or 0
    ///   - lfoBPM: Between 24 and 360
    ///
    public init(
        _ input: AKNode? = nil,
        notchMinimumFrequency: AUValue = 100,
        notchMaximumFrequency: AUValue = 800,
        notchWidth: AUValue = 1_000,
        notchFrequency: AUValue = 1.5,
        vibratoMode: AUValue = 1,
        depth: AUValue = 1,
        feedback: AUValue = 0,
        inverted: AUValue = 0,
        lfoBPM: AUValue = 30
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.notchMinimumFrequency = notchMinimumFrequency
        self.notchMaximumFrequency = notchMaximumFrequency
        self.notchWidth = notchWidth
        self.notchFrequency = notchFrequency
        self.vibratoMode = vibratoMode
        self.depth = depth
        self.feedback = feedback
        self.inverted = inverted
        self.lfoBPM = lfoBPM
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
