// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Delay Audio Unit
///
public class Delay: Node, Toggleable {
    let delayAU = AVAudioUnitDelay()

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
       identifier: "dryWetMix",
       name: "Dry-Wet Mix",
       address: akGetParameterAddress("DelayParameterDryWetMix"),
       range: 0.0 ... 1.0,
       unit: .generic,
       flags: .default)

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue
    
    /// Specification details for time
    public static let timeDef = NodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("DelayParameterTime"),
        range: 0 ... 2.0,
        unit: .seconds,
        flags: .default)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter(timeDef) public var time: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("DelayParameterFeedback"),
        range: -100 ... 100,
        unit: .generic,
        flags: .default)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification details for lowPassCutoff
    public static let lowPassCutoffDef = NodeParameterDef(
        identifier: "lowPassCutoff",
        name: "Low Pass Cutoff Frequency",
        address: akGetParameterAddress("DelayParameterLowPassCutoff"),
        range: 10 ... 22050,
        unit: .hertz,
        flags: .default)

    /// Low-pass cutoff frequency Cutoff Frequency (Hertz) ranges from 10 to 200 (Default: 80)
    @Parameter(lowPassCutoffDef) public var lowPassCutoff: AUValue

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the delay node
    ///
    /// - Parameters:
    ///   - input: Input audio Node to process
    ///   - time: Delay time in seconds (Default: 1)
    ///   - feedback: Amount of feedback, ranges from 0 to 100 (Default: 50)
    ///   - lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    ///   - dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio, ranges from 0 to 100 (Default: 50.0)
    ///
    public init(
        _ input: Node,
        time: AUValue = 1,
        feedback: AUValue = 50,
        lowPassCutoff: AUValue = 15_000,
        dryWetMix: AUValue = 50) {

        super.init(avAudioUnit: delayAU)
        connections.append(input)

        self.$dryWetMix.associate(with: delayAU, index: 0)
        self.$time.associate(with: delayAU, index: 1)
        self.$feedback.associate(with: delayAU, index: 2)
        self.$lowPassCutoff.associate(with: delayAU, index: 3)

        self.dryWetMix = dryWetMix
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        isStarted = true
        delayAU.bypass = false
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        isStarted = false
        delayAU.bypass = true
    }
}
