// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
public class AKPhaser: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let notchMinimumFrequencyDef = AKNodeParameterDef(
        identifier: "notchMinimumFrequency",
        name: "Notch Minimum Frequency",
        address: akGetParameterAddress("AKPhaserParameterNotchMinimumFrequency"),
        range: 20 ... 5_000,
        unit: .hertz,
        flags: .default)

    /// Notch Minimum Frequency
    @Parameter public var notchMinimumFrequency: AUValue

    public static let notchMaximumFrequencyDef = AKNodeParameterDef(
        identifier: "notchMaximumFrequency",
        name: "Notch Maximum Frequency",
        address: akGetParameterAddress("AKPhaserParameterNotchMaximumFrequency"),
        range: 20 ... 10_000,
        unit: .hertz,
        flags: .default)

    /// Notch Maximum Frequency
    @Parameter public var notchMaximumFrequency: AUValue

    public static let notchWidthDef = AKNodeParameterDef(
        identifier: "notchWidth",
        name: "Between 10 and 5000",
        address: akGetParameterAddress("AKPhaserParameterNotchWidth"),
        range: 10 ... 5_000,
        unit: .hertz,
        flags: .default)

    /// Between 10 and 5000
    @Parameter public var notchWidth: AUValue

    public static let notchFrequencyDef = AKNodeParameterDef(
        identifier: "notchFrequency",
        name: "Between 1.1 and 4",
        address: akGetParameterAddress("AKPhaserParameterNotchFrequency"),
        range: 1.1 ... 4.0,
        unit: .hertz,
        flags: .default)

    /// Between 1.1 and 4
    @Parameter public var notchFrequency: AUValue

    public static let vibratoModeDef = AKNodeParameterDef(
        identifier: "vibratoMode",
        name: "Direct or Vibrato (default)",
        address: akGetParameterAddress("AKPhaserParameterVibratoMode"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Direct or Vibrato (default)
    @Parameter public var vibratoMode: AUValue

    public static let depthDef = AKNodeParameterDef(
        identifier: "depth",
        name: "Between 0 and 1",
        address: akGetParameterAddress("AKPhaserParameterDepth"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Between 0 and 1
    @Parameter public var depth: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Between 0 and 1",
        address: akGetParameterAddress("AKPhaserParameterFeedback"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Between 0 and 1
    @Parameter public var feedback: AUValue

    public static let invertedDef = AKNodeParameterDef(
        identifier: "inverted",
        name: "1 or 0",
        address: akGetParameterAddress("AKPhaserParameterInverted"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// 1 or 0
    @Parameter public var inverted: AUValue

    public static let lfoBPMDef = AKNodeParameterDef(
        identifier: "lfoBPM",
        name: "Between 24 and 360",
        address: akGetParameterAddress("AKPhaserParameterLfoBPM"),
        range: 24 ... 360,
        unit: .generic,
        flags: .default)

    /// Between 24 and 360
    @Parameter public var lfoBPM: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKPhaser.notchMinimumFrequencyDef,
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
            akCreateDSP("AKPhaserDSP")
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
        }

        if let input = input {
            connections.append(input)
        }
    }
}
