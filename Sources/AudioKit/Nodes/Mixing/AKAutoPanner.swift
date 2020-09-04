// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Table-lookup panning with linear interpolation
///
public class AKAutoPanner: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "apan")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: akGetParameterAddress("AKAutoPannerParameterFrequency"),
        range: 0.0...100.0,
        unit: .hertz,
        flags: .default)

    /// Frequency (Hz)
    @Parameter public var frequency: AUValue

    public static let depthDef = AKNodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("AKAutoPannerParameterDepth"),
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Depth
    @Parameter public var depth: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKAutoPanner.frequencyDef,
             AKAutoPanner.depthDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKAutoPannerDSP")
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
        _ input: AKNode,
        frequency: AUValue = 10,
        depth: AUValue = 1.0,
        waveform: AKTable = AKTable(.positiveSine)
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.depth = depth

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.internalAU?.setWavetable(waveform.content)
        }

        connections.append(input)
    }

    // TODO this node needs tests
}
