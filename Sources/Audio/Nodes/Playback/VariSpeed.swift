// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// AudioKit version of Apple's VariSpeed Audio Unit
///
public class VariSpeed: Node {
    public var effectAU: AVAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { effectAU }


    // Rate (rate) ranges form 0.25 to 4.0 (Default: 1.0)
    @Parameter(rateDef) public var rate: AUValue

    /// Specification details for rate
    public static let rateDef = NodeParameterDef(
        identifier: "rate",
        name: "Rate",
        address: AUParameterAddress(kTimePitchParam_Rate),
        defaultValue: 1,
        range: 0.25 ... 4,
        unit: .rate
    )

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return rate != 1.0
    }

    fileprivate var lastKnownRate: AUValue = 1.0

    /// Initialize the varispeed node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
    ///
    public init(_ input: Node, rate: AUValue = 1.0) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_Varispeed)
        effectAU = instantiate(componentDescription: desc)
        associateParams(with: effectAU.auAudioUnit)

        self.rate = rate
        lastKnownRate = rate
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        rate = lastKnownRate
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        lastKnownRate = rate
        rate = 1.0
    }

    // TODO: This node is untested
}
