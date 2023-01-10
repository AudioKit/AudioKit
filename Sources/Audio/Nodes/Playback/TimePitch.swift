// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// AudioKit version of Apple's TimePitch Audio Unit
///
public class TimePitch: Node {
    public var effectAU: AVAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { effectAU }

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    @Parameter(rateDef) public var rate: AUValue

    /// Specification details for rate
    public static let rateDef = NodeParameterDef(
        identifier: "rate",
        name: "Rate",
        address: AUParameterAddress(kTimePitchParam_Rate),
        defaultValue: 1,
        range: 0.03125 ... 32,
        unit: .rate
    )

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    @Parameter(pitchDef) public var pitch: AUValue

    /// Specification details for pitch
    public static let pitchDef = NodeParameterDef(
        identifier: "pitch",
        name: "Pitch",
        address: AUParameterAddress(kTimePitchParam_Pitch),
        defaultValue: 0,
        range: -2400 ... 2400,
        unit: .cents
    )

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    @Parameter(overlapDef) public var overlap: AUValue

    /// Specification details for overlap
    public static let overlapDef = NodeParameterDef(
        identifier: "overlap",
        name: "Overlap",
        address: AUParameterAddress(kNewTimePitchParam_Overlap),
        defaultValue: 8,
        range: 3 ... 32,
        unit: .generic
    )

    /// Initialize the time pitch node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    ///   - pitch: Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    ///   - overlap: Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    ///
    public init(
        _ input: Node,
        rate: AUValue = 1.0,
        pitch: AUValue = 0.0,
        overlap: AUValue = 8.0
    ) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_TimePitch)
        effectAU = instantiate(componentDescription: desc)
        associateParams(with: effectAU.auAudioUnit)

        self.rate = rate
        self.pitch = pitch
        self.overlap = overlap

    }

    // TODO: This node is untested
}
