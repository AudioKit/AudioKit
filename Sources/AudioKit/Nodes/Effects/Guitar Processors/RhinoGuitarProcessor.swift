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
        initialValue: 5.0,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Gain applied before processing.
    @Parameter(preGainDef) public var preGain: AUValue

    /// Specification details for post gain
    public static let postGainDef = NodeParameterDef(
        identifier: "postGain",
        name: "PostGain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterPostGain"),
        initialValue: 0.7,
        range: 0.0 ... 1.0,
        unit: .linearGain,
        flags: .default)

    /// Gain applied after processing.
    @Parameter(postGainDef) public var postGain: AUValue

    /// Specification details for low gain
    public static let lowGainDef = NodeParameterDef(
        identifier: "lowGain",
        name: "Low Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterLowGain"),
        initialValue: 0.0,
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Low frequencies.
    @Parameter(lowGainDef) public var lowGain: AUValue

    /// Specification details for mid gain
    public static let midGainDef = NodeParameterDef(
        identifier: "midGain",
        name: "Mid Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterMidGain"),
        initialValue: 0.0,
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of Middle frequencies.
    @Parameter(midGainDef) public var midGain: AUValue

    /// Specification details for high gain
    public static let highGainDef = NodeParameterDef(
        identifier: "highGain",
        name: "High Frequency Gain",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterHighGain"),
        initialValue: 0.0,
        range: -1.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amount of High frequencies.
    @Parameter(highGainDef) public var highGain: AUValue

    /// Specification details for distortion
    public static let distortionDef = NodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("RhinoGuitarProcessorParameterDistortion"),
        initialValue: 1.0,
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Distortion Amount
    @Parameter(distortionDef) public var distortion: AUValue
    
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
        preGain: AUValue = preGainDef.initialValue,
        postGain: AUValue = postGainDef.initialValue,
        lowGain: AUValue = lowGainDef.initialValue,
        midGain: AUValue = midGainDef.initialValue,
        highGain: AUValue = highGainDef.initialValue,
        distortion: AUValue = distortionDef.initialValue
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
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
