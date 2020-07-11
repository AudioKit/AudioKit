// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "bstr")

    public typealias AKAudioUnitType = AKBoosterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Amplification Factor
    open var gain: AUValue = 1 {
        didSet {
            leftGain.value = gain
            rightGain.value = gain
        }
    }

    /// Left Channel Amplification Factor
    public var leftGain = AKNodeParameter(identifier: "leftGain")

    /// Right Channel Amplification Factor
    public var rightGain = AKNodeParameter(identifier: "rightGain")

    /// Amplification Factor in db
    open var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        gain: AUValue = 1
    ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.leftGain.associate(with: self.internalAU, value: gain)
            self.rightGain.associate(with: self.internalAU, value: gain)

            input?.connect(to: self)
        }
    }
}
