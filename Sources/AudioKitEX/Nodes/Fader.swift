// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKitEX

/// Stereo Fader.
public class Fader: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "fder")

    // MARK: - Parameters

    /// Amplification Factor, from 0 ... 4
    open var gain: AUValue = 1 {
        willSet {
            leftGain = newValue
            rightGain = newValue
        }
    }

    /// Allow gain to be any non-negative number
    public static let gainRange: ClosedRange<AUValue> = 0.0 ... Float.greatestFiniteMagnitude

    /// Specification details for left gain
    public static let leftGainDef = NodeParameterDef(
        identifier: "leftGain",
        name: "Left Gain",
        address: akGetParameterAddress("FaderParameterLeftGain"),
        defaultValue: 1,
        range: Fader.gainRange,
        unit: .linearGain)

    /// Left Channel Amplification Factor
    @Parameter(leftGainDef) public var leftGain: AUValue

    /// Specification details for right gain
    public static let rightGainDef = NodeParameterDef(
        identifier: "rightGain",
        name: "Right Gain",
        address: akGetParameterAddress("FaderParameterRightGain"),
        defaultValue: 1,
        range: Fader.gainRange,
        unit: .linearGain)

    /// Right Channel Amplification Factor
    @Parameter(rightGainDef) public var rightGain: AUValue

    /// Amplification Factor in db
    public var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Whether or not to flip left and right channels
    public static let flipStereoDef = NodeParameterDef(
        identifier: "flipStereo",
        name: "Flip Stereo",
        address: akGetParameterAddress("FaderParameterFlipStereo"),
        defaultValue: 0,
        range: 0.0 ... 1.0,
        unit: .boolean)

    /// Flip left and right signal
    @Parameter(flipStereoDef) public var flipStereo: Bool

    /// Specification for whether to mix the stereo signal down to mono
    public static let mixToMonoDef = NodeParameterDef(
        identifier: "mixToMono",
        name: "Mix To Mono",
        address: akGetParameterAddress("FaderParameterMixToMono"),
        defaultValue: 0,
        range: 0.0 ... 1.0,
        unit: .boolean)

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    @Parameter(mixToMonoDef) public var mixToMono: Bool

    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: Node, gain: AUValue = 1) {
        self.input = input

        setupParameters()

        leftGain = gain
        rightGain = gain
        flipStereo = false
        mixToMono = false
    }

    deinit {
        // Log("* { Fader }")
    }
}

extension Fader {
    // MARK: - Automation

    /// Gain automation helper
    /// - Parameters:
    ///   - events: List of events
    ///   - startTime: start time
    public func automateGain(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        $leftGain.automate(events: events, startTime: startTime)
        $rightGain.automate(events: events, startTime: startTime)
    }

    public func automateGain(events: [AutomationEvent], offset: TimeInterval, startTime: AVAudioTime? = nil) {
        $leftGain.automate(events: events, offset: offset, startTime: startTime)
        $rightGain.automate(events: events, offset: offset, startTime: startTime)
    }

    /// Linear ramp the gain in real time
    /// - Parameters:
    ///   - start: Value to start at
    ///   - target: Value to ramp to
    ///   - duration: the duration to ramp
    public func rampGain(from start: AUValue,
                         to target: AUValue,
                         duration: Float,
                         tapered: Bool = true,
                         startTime scheduledTime: AVAudioTime? = nil) {
        // then ramp to the target
        if tapered {
            taperedRamp(from: start, to: target, duration: duration, startTime: scheduledTime)
        } else {
            $leftGain.ramp(from: start, to: target, duration: duration, startTime: scheduledTime)
            $rightGain.ramp(from: start, to: target, duration: duration, startTime: scheduledTime)
        }
    }

    /// Stop automation
    public func stopAutomation() {
        $leftGain.stopAutomation()
        $rightGain.stopAutomation()
    }
}

extension Fader {
    /// Tapered Ramp from a source value to a target value
    ///
    /// - Parameters:
    ///   - start: initial value
    ///   - target: destination value
    ///   - duration: duration to ramp to the target value in seconds
    ///   - rampTaper: Taper, default is 3 for fade in, 1/3 for fade out
    ///   - rampSkew: Skew, default is 1/3 for fade in, and 3 for fade out
    ///   - resolution: Segment duration, default 20ms
    fileprivate func taperedRamp(from start: AUValue,
                            to target: AUValue,
                            duration: AUValue,
                            rampTaper: AUValue = 3,
                            rampSkew: AUValue = 0.333,
                            resolution: AUValue = 0.02,
                            startTime scheduledTime: AVAudioTime? = nil) {
        stopAutomation()

        let startTime: AUValue = 0.02
        var rampTaper = rampTaper
        var rampSkew = rampSkew

        if target < start {
            rampTaper = 1 / rampTaper
            rampSkew = 1 / rampSkew
        }

        // Somewhat of a hack, but...
        // this insures we get a AUEventSampleTimeImmediate set to the start value
        let setupEvents = [
            AutomationEvent(targetValue: start, startTime: 0, rampDuration: 0),
            AutomationEvent(targetValue: start, startTime: startTime + 0.01, rampDuration: 0.01)
        ]

        let points = [
            ParameterAutomationPoint(targetValue: start,
                                     startTime: startTime + 0.02,
                                     rampDuration: 0.02,
                                     rampTaper: rampTaper,
                                     rampSkew: rampSkew),

            ParameterAutomationPoint(targetValue: target,
                                     startTime: startTime + 0.04,
                                     rampDuration: duration - 0.04,
                                     rampTaper: rampTaper,
                                     rampSkew: rampSkew)
        ]
        let curve = AutomationCurve(points: points)
        let events = setupEvents + curve.evaluate(initialValue: start,
                                                  resolution: resolution)

        $leftGain.automate(events: events, startTime: scheduledTime)
        $rightGain.automate(events: events, startTime: scheduledTime)
    }
}
