// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Guitar head and cab simulator.
///
public class RhinoGuitarProcessor: Node, AudioUnitContainer, Toggleable {

    public static let ComponentDescription = AudioComponentDescription(effect: "dlrh")

    public typealias AudioUnitType = InternalAU

    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    public static let preGainDef = NodeParameterDef(
        identifier: "preGain",
        name: "PreGain",
        address: akGetParameterAddress("RhinoGuitarProcessorPreGain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Gain applied before processing.
    @Parameter public var preGain: AUValue

    public static let postGainDef = NodeParameterDef(
        identifier: "postGain",
        name: "PostGain",
        address: akGetParameterAddress("RhinoGuitarProcessorPostGain"),
        range: 0.0 ... 1.0,
        unit: .linearGain,
        flags: .default)

    /// Gain applied after processing.
    @Parameter public var postGain: AUValue

    public static let lowGainDef = NodeParameterDef(
        identifier: "lowGain",
        name: "Low Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorLowGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Low frequencies.
    @Parameter public var lowGain: AUValue

    public static let midGainDef = NodeParameterDef(
        identifier: "midGain",
        name: "Mid Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorMidGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Middle frequencies.
    @Parameter public var midGain: AUValue

    public static let highGainDef = NodeParameterDef(
        identifier: "highGain",
        name: "High Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorHighGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of High frequencies.
    @Parameter public var highGain: AUValue

    public static let distortionDef = NodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("RhinoGuitarProcessorDistortion"),
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Distortion Amount
    @Parameter public var distortion: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {

        public override func getParameterDefs() -> [NodeParameterDef] {
            [RhinoGuitarProcessor.preGainDef,
            RhinoGuitarProcessor.postGainDef,
            RhinoGuitarProcessor.lowGainDef,
            RhinoGuitarProcessor.midGainDef,
            RhinoGuitarProcessor.highGainDef,
            RhinoGuitarProcessor.distortionDef]
        }

        public override func createDSP() -> DSPRef {
            akCreateDSP("RhinoGuitarProcessorDSP")
        }
    }
    // MARK: - Initialization

    /// Initialize this Rhino head and cab simulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - preGain: Determines the amount of gain applied to the signal before processing.
    ///   - postGain: Gain applied after processing.
    ///   - lowGain: Amount of Low frequencies.
    ///   - midGain: Amount of Middle frequencies.
    ///   - highGain: Amount of High frequencies.
    ///   - distortion: Distortion Amount
    ///
    public init(
        _ input: Node,
        preGain: AUValue = 5.0,
        postGain: AUValue = 0.7,
        lowGain: AUValue = 0.0,
        midGain: AUValue = 0.0,
        highGain: AUValue = 0.0,
        distortion: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.preGain = preGain
        self.postGain = postGain
        self.lowGain = lowGain
        self.midGain = midGain
        self.highGain = highGain
        self.distortion = distortion

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }

        connections.append(input)
    }
}
