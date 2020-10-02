// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///
public class DynaRageCompressor: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "dyrc"
    public static let ComponentDescription = AudioComponentDescription(effect: "dyrc")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for ratio
    public static let ratioDef = NodeParameterDef(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: akGetParameterAddress("DynaRageCompressorRatio"),
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Ratio to compress with, a value > 1 will compress
    @Parameter public var ratio: AUValue

    /// Specification details for threshold
    public static let thresholdDef = NodeParameterDef(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: akGetParameterAddress("DynaRageCompressorParameterThreshold"),
        range: -100.0 ... 0.0,
        unit: .decibels,
        flags: .default)

    /// Threshold (in dB) 0 = max
    @Parameter public var threshold: AUValue

    /// Specification details for attack duration
    public static let attackDurationDef = NodeParameterDef(
        identifier: "attackDuration",
        name: "Attack Duration",
        address: akGetParameterAddress("DynaRageCompressorParameterAttackDuration"),
        range: 0.1 ... 500.0,
        unit: .seconds,
        flags: .default)

    /// Attack dration
    @Parameter public var attackDuration: AUValue

    /// Specification details for release duration
    public static let releaseDurationDef = NodeParameterDef(
        identifier: "releaseDuration",
        name: "Release Duration",
        address: akGetParameterAddress("DynaRageCompressorParameterReleaseDuration"),
        range: 1.0 ... 20.0,
        unit: .seconds,
        flags: .default)

    /// Release duration
    @Parameter public var releaseDuration: AUValue

    /// Specification details for rage amount
    public static let rageDef = NodeParameterDef(
        identifier: "rage",
        name: "Rage",
        address: akGetParameterAddress("DynaRageCompressorParameterRage"),
        range: 0.1 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Rage Amount
    @Parameter public var rage: AUValue

    /// Specification details for range enabling
    public static let rageEnabledDef = NodeParameterDef(
        identifier: "rageEnabled",
        name: "Rage Enabled",
        address: akGetParameterAddress("DynaRageCompressorParameterRageEnabled"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Rage ON/OFF Switch
    @Parameter public var rageEnabled: Bool

    // MARK: - Audio Unit

    /// Internal audio unit for DynaRageCompressor
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            [DynaRageCompressor.ratioDef,
             DynaRageCompressor.thresholdDef,
             DynaRageCompressor.attackDurationDef,
             DynaRageCompressor.releaseDurationDef,
             DynaRageCompressor.rageDef,
             DynaRageCompressor.rageEnabledDef]
        }

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("DynaRageCompressorDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackDuration: Attack duration in seconds
    ///   - releaseDuration: Release duration in seconds
    ///
    public init(
        _ input: Node,
        ratio: AUValue = 1,
        threshold: AUValue = 0.0,
        attackDuration: AUValue = 0.1,
        releaseDuration: AUValue = 0.1,
        rage: AUValue = 0.1,
        rageEnabled: Bool = true
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.rage = rage
        self.rageEnabled = rageEnabled

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }

        connections.append(input)
    }
}
