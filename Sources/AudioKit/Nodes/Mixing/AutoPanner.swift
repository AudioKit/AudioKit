// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Table-lookup panning with linear interpolation
///
public class AutoPanner: Node, AudioUnitContainer, Toggleable {

    public static let ComponentDescription = AudioComponentDescription(effect: "apan")

    public typealias AudioUnitType = InternalAU

    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: akGetParameterAddress("AutoPannerParameterFrequency"),
        range: 0.0...100.0,
        unit: .hertz,
        flags: .default)

    /// Frequency (Hz)
    @Parameter public var frequency: AUValue

    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("AutoPannerParameterDepth"),
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Depth
    @Parameter public var depth: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {

        public override func getParameterDefs() -> [NodeParameterDef] {
            [AutoPanner.frequencyDef,
             AutoPanner.depthDef]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("AutoPannerDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this auto panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///   - waveform:  Shape of the panner (default to sine)
    ///
    public init(
        _ input: Node,
        frequency: AUValue = 10,
        depth: AUValue = 1.0,
        waveform: Table = Table(.positiveSine)
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.internalAU?.setWavetable(waveform.content)
            self.frequency = frequency
            self.depth = depth
        }

        connections.append(input)
    }
}
