// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
/// TODO: This node needs tests
public class StereoDelay: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "sdly")

    // MARK: - Parameters

    /// Specification details for time
    public static let timeDef = NodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("StereoDelayParameterTime"),
        defaultValue: 0,
        range: 0 ... 2.0,
        unit: .seconds)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter(timeDef) public var time: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("StereoDelayParameterFeedback"),
        defaultValue: 0,
        range: 0.0 ... 1.0,
        unit: .generic)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry-Wet Mix",
        address: akGetParameterAddress("StereoDelayParameterDryWetMix"),
        defaultValue: 0.5,
        range: 0.0 ... 1.0,
        unit: .generic)

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue

    /// Specification details for ping pong mode
    public static let pingPongDef = NodeParameterDef(
        identifier: "pingPong",
        name: "Ping-Pong Mode",
        address: akGetParameterAddress("StereoDelayParameterPingPong"),
        defaultValue: 0,
        range: 0.0...1.0,
        unit: .boolean,
        flags: [.flag_IsReadable, .flag_IsWritable])

    /// Ping-pong mode: true or false (stereo mode)
    @Parameter(pingPongDef) public var pingPong: AUValue

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - dryWetMix: Dry/wet mix. Should be a value between 0-1.
    ///   - pingPong: true for ping-pong mode, false for stereo mode.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: Node,
        time: AUValue = timeDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        dryWetMix: AUValue = dryWetMixDef.defaultValue,
        pingPong: Bool = (dryWetMixDef.defaultValue == 1.0),
        maximumDelayTime: AUValue = 2.0
    ) {
        self.input = input
        
        setupParameters()
        
        self.time = time
        self.feedback = feedback
        self.dryWetMix = dryWetMix
        self.pingPong = pingPong ? 1.0 : 0.0
    }
}
