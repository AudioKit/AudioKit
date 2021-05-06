// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Guitar head and cab simulator.
///
public class RhinoGuitarProcessor: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "rhgp"
    public static let ComponentDescription = AudioComponentDescription(effect: "rhgp")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for pre gain
    public static let preGainDef = NodeParameterDef(
        identifier: "preGain",
        name: "PreGain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterPreGain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Gain applied before processing.
    @Parameter2(preGainDef) public var preGain: AUValue

    /// Specification details for post gain
    public static let postGainDef = NodeParameterDef(
        identifier: "postGain",
        name: "PostGain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterPostGain"),
        range: 0.0 ... 1.0,
        unit: .linearGain,
        flags: .default)

    /// Gain applied after processing.
    @Parameter2(postGainDef) public var postGain: AUValue

    /// Specification details for low gain
    public static let lowGainDef = NodeParameterDef(
        identifier: "lowGain",
        name: "Low Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterLowGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Low frequencies.
    @Parameter2(lowGainDef) public var lowGain: AUValue

    /// Specification details for mid gain
    public static let midGainDef = NodeParameterDef(
        identifier: "midGain",
        name: "Mid Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterMidGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Middle frequencies.
    @Parameter2(midGainDef) public var midGain: AUValue

    /// Specification details for high gain
    public static let highGainDef = NodeParameterDef(
        identifier: "highGain",
        name: "High Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterHighGain"),
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of High frequencies.
    @Parameter2(highGainDef) public var highGain: AUValue

    /// Specification details for distortion
    public static let distortionDef = NodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterDistortion"),
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Distortion Amount
    @Parameter2(distortionDef) public var distortion: AUValue
    
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

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.preGain = preGain
            self.postGain = postGain
            self.lowGain = lowGain
            self.midGain = midGain
            self.highGain = highGain
            self.distortion = distortion

        }

        connections.append(input)
    }
}
