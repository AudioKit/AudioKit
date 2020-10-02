// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
public class StereoDelay: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "sdly"
    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for time
    public static let timeDef = NodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("StereoDelayParameterTime"),
        range: 0 ... 2.0,
        unit: .seconds,
        flags: .default)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter public var time: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("StereoDelayParameterFeedback"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter public var feedback: AUValue

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
       identifier: "dryWetMix",
       name: "Dry-Wet Mix",
       address: akGetParameterAddress("StereoDelayParameterDryWetMix"),
       range: 0.0 ... 1.0,
       unit: .generic,
       flags: .default)

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter public var dryWetMix: AUValue

    /// Specification details for ping pong mode
    public static let pingPongDef = NodeParameterDef(
       identifier: "pingPong",
       name: "Ping-Pong Mode",
       address: akGetParameterAddress("StereoDelayParameterPingPong"),
       range: 0.0...1.0,
       unit: .boolean,
       flags: [.flag_IsReadable, .flag_IsWritable])

    /// Ping-pong mode: true or false (stereo mode)
    @Parameter public var pingPong: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for Stereo Delay
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            [StereoDelay.timeDef,
             StereoDelay.feedbackDef,
             StereoDelay.dryWetMixDef,
             StereoDelay.pingPongDef]
        }

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("StereoDelayDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - dryWetMix: Dry/wet mix. Should be a value between 0-1.
    ///   - pingPong: true for ping-pong mode, false for stereo mode.
    ///
    public init(
        _ input: Node,
        maximumDelayTime: AUValue = 2.0,
        time: AUValue = 0,
        feedback: AUValue = 0,
        dryWetMix: AUValue = 0.5,
        pingPong: Bool = false
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.time = time
            self.feedback = feedback
            self.dryWetMix = dryWetMix
            self.pingPong = pingPong ? 1.0 : 0.0
        }

        connections.append(input)
    }
}
