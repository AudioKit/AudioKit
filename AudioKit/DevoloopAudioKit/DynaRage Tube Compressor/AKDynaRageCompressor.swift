// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///
open class AKDynaRageCompressor: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "dldr")

    public typealias AKAudioUnitType = AKDynaRageCompressorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Ratio to compress with, a value > 1 will compress
    @Parameter public var ratio: AUValue

    /// Threshold (in dB) 0 = max
    @Parameter public var threshold: AUValue

    /// Attack dration
    @Parameter public var attackDuration: AUValue

    /// Release duration
    @Parameter public var releaseDuration: AUValue

    /// Rage Amount
    @Parameter public var rage: AUValue

    /// Rage ON/OFF Switch
    @Parameter public var rageIsOn: Bool

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
    @objc public init(
        _ input: AKNode? = nil,
        ratio: AUValue = 1,
        threshold: AUValue = 0.0,
        attackDuration: AUValue = 0.1,
        releaseDuration: AUValue = 0.1,
        rage: AUValue = 0.1,
        rageIsOn: Bool = true
    ) {
        super.init(avAudioNode: AVAudioNode())
        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.rage = rage
        self.rageIsOn = rageIsOn

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
