// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// AudioKit version of Apple's Delay Audio Unit
///
public class Delay: Node {
    let delayAU = AVAudioUnitDelay()

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }
    
    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { return delayAU }

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry-Wet Mix",
        address: 0,
        defaultValue: 50,
        range: 0.0 ... 1.0,
        unit: .generic)

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue
    
    /// Specification details for time
    public static let timeDef = NodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: 1,
        defaultValue: 1,
        range: 0 ... 2.0,
        unit: .seconds)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter(timeDef) public var time: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: 2,
        defaultValue: 50,
        range: -100 ... 100,
        unit: .generic)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification details for lowPassCutoff
    public static let lowPassCutoffDef = NodeParameterDef(
        identifier: "lowPassCutoff",
        name: "Low Pass Cutoff Frequency",
        address: 3,
        defaultValue: 15000,
        range: 10 ... 22050,
        unit: .hertz)

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
        time: AUValue = timeDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        lowPassCutoff: AUValue = lowPassCutoffDef.defaultValue,
        dryWetMix: AUValue = dryWetMixDef.defaultValue) {

        self.input = input

        associateParams(with: delayAU)

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
