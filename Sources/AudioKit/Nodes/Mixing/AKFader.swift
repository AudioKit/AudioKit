// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo Fader. Similar to AKBooster but with the addition of
/// Automation support.
public class AKFader: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public typealias AKAudioUnitType = InternalAU

    public static let ComponentDescription = AudioComponentDescription(effect: "fder")

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Amplification Factor, from 0 ... 4
    open var gain: AUValue = 1 {
        willSet {
            leftGain = gain
            rightGain = gain
        }
    }

    public static let gainRange: ClosedRange<AUValue> = 0.0 ... 4.0

    public static let leftGainDef = AKNodeParameterDef(
        identifier: "leftGain",
        name: "Left Gain",
        address: akGetParameterAddress("AKFaderParameterLeftGain"),
        range: AKFader.gainRange,
        unit: .linearGain,
        flags: .default)

    /// Left Channel Amplification Factor
    @Parameter public var leftGain: AUValue

    public static let rightGainDef = AKNodeParameterDef(
        identifier: "rightGain",
        name: "Right Gain",
        address: akGetParameterAddress("AKFaderParameterRightGain"),
        range: AKFader.gainRange,
        unit: .linearGain,
        flags: .default)

    /// Right Channel Amplification Factor
    @Parameter public var rightGain: AUValue

    /// Amplification Factor in db
    public var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    public static let flipStereoDef = AKNodeParameterDef(
        identifier: "flipStereo",
        name: "Flip Stereo",
        address: akGetParameterAddress("AKFaderParameterFlipStereo"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Flip left and right signal
    @Parameter public var flipStereo: Bool = false

    public static let mixToMonoDef = AKNodeParameterDef(
        identifier: "mixToMono",
        name: "Mix To Mono",
        address: akGetParameterAddress("AKFaderParameterMixToMono"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    @Parameter public var mixToMono: Bool = false

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKFader.leftGainDef,
             AKFader.rightGainDef,
             AKFader.flipStereoDef,
             AKFader.mixToMonoDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKFaderDSP")
        }
    }
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
        self.leftGain = gain
        self.rightGain = gain

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }

    deinit {
        AKLog("* { AKFader }")
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

        parameterAutomation?.add(point: point, to: $leftGain)
        parameterAutomation?.add(point: point, to: $rightGain)
    }

    /// Convenience function for clearing all points for both left and right addresses
    public func clearAutomationPoints() {
        parameterAutomation?.clearAllPoints(of: $leftGain)
        parameterAutomation?.clearAllPoints(of: $rightGain)
    }

    // MARK: - Automation

    public func automateGain(events: [AKAutomationEvent], startTime: AVAudioTime? = nil) {
        $leftGain.automate(events: events, startTime: startTime)
        $rightGain.automate(events: events, startTime: startTime)
    }

    public func stopAutomation() {
        $leftGain.stopAutomation()
        $rightGain.stopAutomation()
    }
}
