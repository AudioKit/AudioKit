// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///
public class AKDynaRageCompressor: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "dldr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let ratioDef = AKNodeParameterDef(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: akGetParameterAddress("AKDynaRageCompressorRatio"),
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Ratio to compress with, a value > 1 will compress
    @Parameter public var ratio: AUValue

    public static let thresholdDef = AKNodeParameterDef(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: akGetParameterAddress("AKDynaRageCompressorParameterThreshold"),
        range: -100.0 ... 0.0,
        unit: .decibels,
        flags: .default)

    /// Threshold (in dB) 0 = max
    @Parameter public var threshold: AUValue

    public static let attackDurationDef = AKNodeParameterDef(
        identifier: "attackDuration",
        name: "Attack Duration",
        address: akGetParameterAddress("AKDynaRageCompressorParameterAttackDuration"),
        range: 0.1 ... 500.0,
        unit: .seconds,
        flags: .default)

    /// Attack dration
    @Parameter public var attackDuration: AUValue

    public static let releaseDurationDef = AKNodeParameterDef(
        identifier: "releaseDuration",
        name: "Release Duration",
        address: akGetParameterAddress("AKDynaRageCompressorParameterReleaseDuration"),
        range: 1.0 ... 20.0,
        unit: .seconds,
        flags: .default)

    /// Release duration
    @Parameter public var releaseDuration: AUValue

    public static let rageDef = AKNodeParameterDef(
        identifier: "rage",
        name: "Rage",
        address: akGetParameterAddress("AKDynaRageCompressorParameterRage"),
        range: 0.1 ... 20.0,
        unit: .generic,
        flags: .default)

    /// Rage Amount
    @Parameter public var rage: AUValue

    public static let rageEnabledDef = AKNodeParameterDef(
        identifier: "rageEnabled",
        name: "Rage Enabled",
        address: akGetParameterAddress("AKDynaRageCompressorParameterRageEnabled"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Rage ON/OFF Switch
    @Parameter public var rageEnabled: Bool

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKDynaRageCompressor.ratioDef,
             AKDynaRageCompressor.thresholdDef,
             AKDynaRageCompressor.attackDurationDef,
             AKDynaRageCompressor.releaseDurationDef,
             AKDynaRageCompressor.rageDef,
             AKDynaRageCompressor.rageEnabledDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKDynaRageCompressorDSP")
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
        _ input: AKNode,
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

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        connections.append(input)
    }
}
