// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
///
public class AKStereoDelay: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let timeDef = AKNodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("AKStereoDelayParameterTime"),
        range: 0 ... 2.0,
        unit: .seconds,
        flags: .default)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter public var time: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("AKStereoDelayParameterFeedback"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter public var feedback: AUValue

    public static let dryWetMixDef = AKNodeParameterDef(
       identifier: "dryWetMix",
       name: "Dry-Wet Mix",
       address: akGetParameterAddress("AKStereoDelayParameterDryWetMix"),
       range: 0.0 ... 1.0,
       unit: .generic,
       flags: .default)

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter public var dryWetMix: AUValue

    public static let pingPongDef = AKNodeParameterDef(
       identifier: "pingPong",
       name: "Ping-Pong Mode",
       address: akGetParameterAddress("AKStereoDelayParameterPingPong"),
       range: 0.0...1.0,
       unit: .boolean,
       flags: [.flag_IsReadable, .flag_IsWritable])

    /// Ping-pong mode: true or false (stereo mode)
    @Parameter public var pingPong: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKStereoDelay.timeDef,
             AKStereoDelay.feedbackDef,
             AKStereoDelay.dryWetMixDef,
             AKStereoDelay.pingPongDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKStereoDelayDSP")
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
        _ input: AKNode,
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

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.time = time
            self.feedback = feedback
            self.dryWetMix = dryWetMix
            self.pingPong = pingPong ? 1.0 : 0.0
        }

        connections.append(input)
    }
}
