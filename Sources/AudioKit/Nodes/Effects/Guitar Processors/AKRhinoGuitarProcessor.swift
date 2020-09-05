// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Guitar head and cab simulator.
///
public class AKRhinoGuitarProcessor: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "dlrh")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let preGainDef = AKNodeParameterDef(
        identifier: "preGain",
        name: "PreGain",
        address: akGetParameterAddress("AKRhinoGuitarProcessorPreGain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Gain applied before processing.
    @Parameter public var preGain: AUValue

    public static let postGainDef = AKNodeParameterDef(
        identifier: "postGain",
        name: "PostGain",
        address: akGetParameterAddress("AKRhinoGuitarProcessorPostGain"),
        range: 0.0 ... 1.0,
        unit: .linearGain,
        flags: .default)

    /// Gain applied after processing.
    @Parameter public var postGain: AUValue

    public static let lowGainDef = AKNodeParameterDef(
        identifier: "lowGain",
        name: "Low Frequency Gain",
        address: akGetParameterAddress("AKRhinoGuitarProcessorLowGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Low frequencies.
    @Parameter public var lowGain: AUValue

    public static let midGainDef = AKNodeParameterDef(
        identifier: "midGain",
        name: "Mid Frequency Gain",
        address: akGetParameterAddress("AKRhinoGuitarProcessorMidGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Middle frequencies.
    @Parameter public var midGain: AUValue

    public static let highGainDef = AKNodeParameterDef(
        identifier: "highGain",
        name: "High Frequency Gain",
        address: akGetParameterAddress("AKRhinoGuitarProcessorHighGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of High frequencies.
    @Parameter public var highGain: AUValue

    public static let distortionDef = AKNodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("AKRhinoGuitarProcessorDistortion"),
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Distortion Amount
    @Parameter public var distortion: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKRhinoGuitarProcessor.preGainDef,
            AKRhinoGuitarProcessor.postGainDef,
            AKRhinoGuitarProcessor.lowGainDef,
            AKRhinoGuitarProcessor.midGainDef,
            AKRhinoGuitarProcessor.highGainDef,
            AKRhinoGuitarProcessor.distortionDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKRhinoGuitarProcessorDSP")
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
        _ input: AKNode,
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
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        connections.append(input)
    }
}
