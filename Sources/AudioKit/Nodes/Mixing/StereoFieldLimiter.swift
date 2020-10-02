// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo StereoFieldLimiter
///
public class StereoFieldLimiter: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "sflm"
    public static let ComponentDescription = AudioComponentDescription(effect: "sflm")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Properties

    /// Specification details for amount
    public static let amountDef = NodeParameterDef(
        identifier: "amount",
        name: "Limiting amount",
        address: akGetParameterAddress("StereoFieldLimiterAmount"),
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    /// Limiting Factor
    @Parameter public var amount: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for stereo field limiter
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            [StereoFieldLimiter.amountDef]
        }

        /// Create stereo field limiter DSP
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("StereoFieldLimiterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this stereo field limiter node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be amplified
    ///   - amount: limit factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: Node, amount: AUValue = 1) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.amount = amount
        }
        connections.append(input)
    }
}
