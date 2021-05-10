// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///
public class DynaRageCompressor: Node {

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "dyrc")
    
    // MARK: - Parameters

    /// Specification details for ratio
    public static let ratioDef = NodeParameterDef(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: akGetParameterAddress("DynaRageCompressorParameterRatio"),
        defaultValue: 1,
        range: 1.0 ... 20.0,
        unit: .generic)

    /// Ratio to compress with, a value > 1 will compress
    @Parameter(ratioDef) public var ratio: AUValue

    /// Specification details for threshold
    public static let thresholdDef = NodeParameterDef(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: akGetParameterAddress("DynaRageCompressorParameterThreshold"),
        defaultValue: 0.0,
        range: -100.0 ... 0.0,
        unit: .decibels)

    /// Threshold (in dB) 0 = max
    @Parameter(thresholdDef) public var threshold: AUValue

    /// Specification details for attack duration
    public static let attackDurationDef = NodeParameterDef(
        identifier: "attackDuration",
        name: "Attack Duration",
        address: akGetParameterAddress("DynaRageCompressorParameterAttackDuration"),
        defaultValue: 0.1,
        range: 0.1 ... 500.0,
        unit: .seconds)

    /// Attack dration
    @Parameter(attackDurationDef) public var attackDuration: AUValue

    /// Specification details for release duration
    public static let releaseDurationDef = NodeParameterDef(
        identifier: "releaseDuration",
        name: "Release Duration",
        address: akGetParameterAddress("DynaRageCompressorParameterReleaseDuration"),
        defaultValue: 0.1,
        range: 1.0 ... 20.0,
        unit: .seconds)

    /// Release duration
    @Parameter(releaseDurationDef) public var releaseDuration: AUValue

    /// Specification details for rage amount
    public static let rageDef = NodeParameterDef(
        identifier: "rage",
        name: "Rage",
        address: akGetParameterAddress("DynaRageCompressorParameterRage"),
        defaultValue: 0.1,
        range: 0.1 ... 20.0,
        unit: .generic)

    /// Rage Amount
    @Parameter(rageDef) public var rage: AUValue

    /// Specification details for range enabling
    public static let rageEnabledDef = NodeParameterDef(
        identifier: "rageEnabled",
        name: "Rage Enabled",
        address: akGetParameterAddress("DynaRageCompressorParameterRageEnabled"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .boolean)

    /// Rage ON/OFF Switch
    @Parameter(rageEnabledDef) public var rageEnabled: Bool

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
        ratio: AUValue = ratioDef.defaultValue,
        threshold: AUValue = thresholdDef.defaultValue,
        attackDuration: AUValue = attackDurationDef.defaultValue,
        releaseDuration: AUValue = releaseDurationDef.defaultValue,
        rage: AUValue = rageDef.defaultValue,
        rageEnabled: Bool = rageEnabledDef.defaultValue == 1.0
    ) {
        self.input = input
        
        setupParameters()
        
        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.rage = rage
        self.rageEnabled = rageEnabled
    }
}
