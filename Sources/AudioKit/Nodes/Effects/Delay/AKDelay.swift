// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Delay Audio Unit
///
public class AKDelay: AKNode, AKToggleable {
    let delayAU = AVAudioUnitDelay()

    @Parameter public var dryWetMix: AUValue
    @Parameter public var time: AUValue
    @Parameter public var feedback: AUValue
    @Parameter public var lowPassCutoff: AUValue

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the delay node
    ///
    /// - Parameters:
    ///   - input: Input audio AKNode to process
    ///   - time: Delay time in seconds (Default: 1)
    ///   - feedback: Amount of feedback, ranges from 0 to 100 (Default: 50)
    ///   - lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    ///   - dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio, ranges from 0 to 100 (Default: 50.0)
    ///
    public init(
        _ input: AKNode,
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
