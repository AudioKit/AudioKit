// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

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
        
        self.leftGain = gain
        self.rightGain = gain
        self.flipStereo = false
        self.mixToMono = false
    }

    deinit {
        // Log("* { Fader }")
    }

    // MARK: - Automation

    /// Gain automation helper
    /// - Parameters:
    ///   - events: List of events
    ///   - startTime: start time
    public func automateGain(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        $leftGain.automate(events: events, startTime: startTime)
        $rightGain.automate(events: events, startTime: startTime)
    }

    /// Stop automation
    public func stopAutomation() {
        $leftGain.stopAutomation()
        $rightGain.stopAutomation()
    }
}
