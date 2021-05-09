// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo StereoFieldLimiter
///
public class StereoFieldLimiter: NodeBase, AudioUnitContainer {

    /// Unique four-letter identifier "sflm"
    public static let ComponentDescription = AudioComponentDescription(effect: "sflm")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    let input: Node
    override public var connections: [Node] { [input] }

    // MARK: - Properties

    /// Specification details for amount
    public static let amountDef = NodeParameterDef(
        identifier: "amount",
        name: "Limiting amount",
        address: akGetParameterAddress("StereoFieldLimiterParameterAmount"),
        defaultValue: 1,
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Limiting Factor
    @Parameter(amountDef) public var amount: AUValue

    // MARK: - Initialization

    /// Initialize this stereo field limiter node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be amplified
    ///   - amount: limit factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: Node, amount: AUValue = amountDef.defaultValue) {
        self.input = input
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.amount = amount
        }
    }
}
