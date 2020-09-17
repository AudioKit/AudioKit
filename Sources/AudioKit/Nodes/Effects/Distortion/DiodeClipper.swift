// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
public class DiodeClipper: Node, AudioUnitContainer, Toggleable {

    public static let ComponentDescription = AudioComponentDescription(effect: "dclp")

    public typealias AudioUnitType = InternalAU

    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("DiodeClipperParameterCutoff"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Filter cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

    public static let gainDef = NodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: akGetParameterAddress("DiodeClipperParameterGaindB"),
        range: 0.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter public var gain: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {

        public override func getParameterDefs() -> [NodeParameterDef] {
            [DiodeClipper.cutoffFrequencyDef,
             DiodeClipper.gainDef]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("DiodeClipperDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency
    ///   - gain: Gain in dB
    ///
    public init(
        _ input: Node,
        cutoffFrequency: AUValue = 10000.0,
        gain: AUValue = 20.0
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.cutoffFrequency = cutoffFrequency
            self.gain = gain
        }

        connections.append(input)
    }
}
