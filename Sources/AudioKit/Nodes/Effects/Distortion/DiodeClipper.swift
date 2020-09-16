// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
public class AKDiodeClipper: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "dclp")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let cutoffFrequencyDef = AKNodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("AKDiodeClipperParameterCutoff"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Filter cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

    public static let gainDef = AKNodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: akGetParameterAddress("AKDiodeClipperParameterGaindB"),
        range: 0.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter public var gain: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKDiodeClipper.cutoffFrequencyDef,
             AKDiodeClipper.gainDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKDiodeClipperDSP")
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
        _ input: AKNode,
        cutoffFrequency: AUValue = 10000.0,
        gain: AUValue = 20.0
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.cutoffFrequency = cutoffFrequency
            self.gain = gain
        }

        connections.append(input)
    }
}
