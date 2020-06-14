// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///
open class AKDynaRageCompressor: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dldr")

    public typealias AKAudioUnitType = AKDynaRageCompressorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Ratio to compress with, a value > 1 will compress
    public let ratio = AKNodeParameter(identifier: "ratio")

    /// Threshold (in dB) 0 = max
    public let threshold = AKNodeParameter(identifier: "threshold")

    /// Attack dration
    public let attackDuration = AKNodeParameter(identifier: "attackDuration")

    /// Release duration
    public let releaseDuration = AKNodeParameter(identifier: "releaseDuration")

    /// Rage Amount
    public let rage = AKNodeParameter(identifier: "rage")

    /// Rage ON/OFF Switch
    public let rageIsOn = AKNodeParameter(identifier: "rageIsOn")

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

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.ratio.associate(with: self.internalAU, value: ratio)
            self.threshold.associate(with: self.internalAU, value: threshold)
            self.attackDuration.associate(with: self.internalAU, value: attackDuration)
            self.releaseDuration.associate(with: self.internalAU, value: releaseDuration)
            self.rage.associate(with: self.internalAU, value: rage)
            self.rageIsOn.associate(with: self.internalAU, value: rageIsOn)

            input?.connect(to: self)
        }
    }
}
