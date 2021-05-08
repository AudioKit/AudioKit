// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Table-lookup panning with linear interpolation
///
public class AutoPanner: Node, AudioUnitContainer, Toggleable {

    /// Four letter unique description "apan"
    public static let ComponentDescription = AudioComponentDescription(effect: "apan")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: akGetParameterAddress("AutoPannerParameterFrequency"),
        initialValue: 10,
        range: 0.0...100.0,
        unit: .hertz,
        flags: .default)

    /// Frequency (Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("AutoPannerParameterDepth"),
        initialValue: 1.0,
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Depth
    @Parameter(depthDef) public var depth: AUValue

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
        frequency: AUValue = frequencyDef.initialValue,
        depth: AUValue = depthDef.initialValue,
        waveform: Table = Table(.positiveSine)
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.internalAU?.setWavetable(waveform.content)
            self.frequency = frequency
            self.depth = depth
        }

        connections.append(input)
    }
}
