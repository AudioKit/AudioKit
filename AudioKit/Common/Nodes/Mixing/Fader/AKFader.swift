// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Fader. Similar to AKBooster but with the addition of
/// Automation support.
open class AKFader: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {
    // MARK: - AKComponent

    public typealias AKAudioUnitType = AKFaderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fder")

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static var gainRange: ClosedRange<AUValue> = (0 ... 4)

    /// Amplification Factor, from 0 ... 4
    open var gain: AUValue = 1 {
        willSet {
            leftGain.value = gain
            rightGain.value = gain
        }
    }

    /// Left Channel Amplification Factor
    public var leftGain = AKNodeParameter(identifier: "leftGain")

    /// Right Channel Amplification Factor
    public var rightGain = AKNodeParameter(identifier: "rightGain")

    /// Amplification Factor in db
    public var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Flip left and right signal
    public var flipStereo = AKNodeParameter(identifier: "flipStereo")

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    public var mixToMono = AKNodeParameter(identifier: "mixToMono")

    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode? = nil,
                gain: AUValue = 1) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.leftGain.associate(with: self.internalAU, value: gain)
            self.rightGain.associate(with: self.internalAU, value: gain)
            self.flipStereo.associate(with: self.internalAU, value: false)
            self.mixToMono.associate(with: self.internalAU, value: false)

            input?.connect(to: self)
        }
    }

    deinit {
        AKLog("* { AKFader }")
    }

    open override func detach() {
        super.detach()
        parameterAutomation = nil
    }

    // MARK: - AKAutomatable

    /// Convenience function for adding a pair of points for both left and right addresses
    public func addAutomationPoint(value: AUValue,
                                   at startTime: Double,
                                   rampDuration: Double = 0,
                                   taper taperValue: Float = 1,
                                   skew skewValue: Float = 0) {
        let point = AKParameterAutomationPoint(targetValue: value,
                                               startTime: startTime,
                                               rampDuration: rampDuration,
                                               rampTaper: taperValue,
                                               rampSkew: skewValue)

        parameterAutomation?.add(point: point, to: leftGain.identifier)
        parameterAutomation?.add(point: point, to: rightGain.identifier)
    }

    /// Convenience function for clearing all points for both left and right addresses
    public func clearAutomationPoints() {
        parameterAutomation?.clearAllPoints(of: leftGain.identifier)
        parameterAutomation?.clearAllPoints(of: rightGain.identifier)
    }
}
