// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Delay Audio Unit
///
public class AKDelay: AKNode, AKToggleable {
    let delayAU = AVAudioUnitDelay()

    fileprivate var lastKnownMix: AUValue = 0.5

    /// Delay time in seconds (Default: 1)
    public var time: TimeInterval = 1 {
        didSet {
            time = max(time, 0)
            delayAU.delayTime = time
        }
    }

    /// Feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var feedback: AUValue = 0.5 {
        didSet {
            feedback = (0...1).clamp(feedback)
            delayAU.feedback = feedback * 100.0
        }
    }

    /// Low pass cut-off frequency in Hertz (Default: 15000)
    public var lowPassCutoff: AUValue = 15_000.00 {
        didSet {
            lowPassCutoff = max(lowPassCutoff, 0)
            delayAU.lowPassCutoff = lowPassCutoff
        }
    }

    /// Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var dryWetMix: AUValue = 0.5 {
        didSet {
            internalSetDryWetMix(dryWetMix)
        }
    }

    internal func internalSetDryWetMix(_ value: AUValue) {
        let newValue = (0...1).clamp(value)
        delayAU.wetDryMix = newValue * 100.0
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the delay node
    ///
    /// - Parameters:
    ///   - input: Input audio AKNode to process
    ///   - time: Delay time in seconds (Default: 1)
    ///   - feedback: Amount of feedback, ranges from 0 to 1 (Default: 0.5)
    ///   - lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    ///   - dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio, ranges from 0 to 1 (Default: 0.5)
    ///
    public init(
        _ input: AKNode? = nil,
        time: AUValue = 1,
        feedback: AUValue = 0.5,
        lowPassCutoff: AUValue = 15_000,
        dryWetMix: AUValue = 0.5) {

        self.time = TimeInterval(AUValue(time))
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        self.dryWetMix = dryWetMix

        super.init(avAudioUnit: delayAU)
        if let input = input {
            connections.append(input)
        }

        delayAU.delayTime = self.time
        delayAU.feedback = feedback * 100.0
        delayAU.lowPassCutoff = lowPassCutoff
        internalSetDryWetMix(dryWetMix)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
