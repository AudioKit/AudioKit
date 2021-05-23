// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Transient shaper
public class TransientShaper: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "trsh"
    public static let ComponentDescription = AudioComponentDescription(effect: "trsh")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Input Amount for the plugin in decibels
    public static let inputAmountDef = NodeParameterDef(
        identifier: "inputAmount",
        name: "Input",
        address: akGetParameterAddress("TransientShaperParameterInputAmount"),
        range: -60.0 ... 30.0,
        unit: .decibels,
        flags: .default)

    /// Input Amount
    @Parameter public var inputAmount: AUValue

    /// How much of the attack is heard in decibels
    public static let attackAmountDef = NodeParameterDef(
        identifier: "attackAmount",
        name: "Attack",
        address: akGetParameterAddress("TransientShaperParameterAttackAmount"),
        range: -40.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Attack Amount
    @Parameter public var attackAmount: AUValue

    /// How much of the release is heard in decibels
    public static let releaseAmountDef = NodeParameterDef(
        identifier: "releaseAmount",
        name: "Release",
        address: akGetParameterAddress("TransientShaperParameterReleaseAmount"),
        range: -40.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Release Amount
    @Parameter public var releaseAmount: AUValue

    /// Output Amount for the plugin in decibels
    public static let outputAmountDef = NodeParameterDef(
        identifier: "outputAmount",
        name: "Output",
        address: akGetParameterAddress("TransientShaperParameterOutputAmount"),
        range: -60.0 ... 30.0,
        unit: .decibels,
        flags: .default)

    /// Output Amount
    @Parameter public var outputAmount: AUValue

    /// How long the attack takes in milliseconds
    public static let attackTimeDef = NodeParameterDef(
        identifier: "attackTime",
        name: "Attack Time",
        address: akGetParameterAddress("TransientShaperParameterAttackTime"),
        range: 0 ... 500.0,
        unit: .milliseconds,
        flags: .default)

    /// Attack Time
    @Parameter public var attackTime: AUValue

    /// How long the release takest in seconds
    public static let releaseTimeDef = NodeParameterDef(
        identifier: "releaseTime",
        name: "Release Time",
        address: akGetParameterAddress("TransientShaperParameterReleaseTime"),
        range: 0 ... 5.0,
        unit: .seconds,
        flags: .default)

    /// Attack Time
    @Parameter public var releaseTime: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for Transient Shaper
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef]? {
            [TransientShaper.inputAmountDef,
             TransientShaper.attackAmountDef,
             TransientShaper.releaseAmountDef,
             TransientShaper.outputAmountDef,
             TransientShaper.attackTimeDef,
             TransientShaper.releaseTimeDef]
        }

        /// Create the DSP Reference for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("TransientShaperDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///     - input: Input node to process
    ///     - inputAmount: Input Decibels to the plugin
    ///     - attackAmount: Attack amount in decibels
    ///     - releaseAmount: Release amount in decibels
    ///     - outputAmount: Output Decibels from the plugin
    ///     - attackTime: Milliseconds before attack
    ///     - releaseTime: Seconds before release
    public init(
        _ input: Node,
        inputAmount: AUValue = 0.0,
        attackAmount: AUValue = 0.0,
        releaseAmount: AUValue = 0.0,
        outputAmount: AUValue = 0.0,
        attackTime: AUValue = 20.0,
        releaseTime: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.inputAmount = inputAmount
            self.attackAmount = attackAmount
            self.releaseAmount = releaseAmount
            self.outputAmount = outputAmount
            self.attackTime = attackTime
            self.releaseTime = releaseTime
        }

        connections.append(input)
    }

}
