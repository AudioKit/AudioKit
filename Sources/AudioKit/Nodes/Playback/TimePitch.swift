// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's TimePitch Audio Unit
///
public class AKTimePitch: AKNode, AKToggleable {

    fileprivate let timePitchAU = AVAudioUnitTimePitch()

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    public var rate: AUValue = 1.0 {
        didSet {
            rate = (0.031_25...32).clamp(rate)
            timePitchAU.rate = rate
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return !timePitchAU.bypass
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    public var pitch: AUValue = 0.0 {
        didSet {
            pitch = (-2_400...2_400).clamp(pitch)
            timePitchAU.pitch = pitch
        }
    }

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    public var overlap: AUValue = 8.0 {
        didSet {
            overlap = (3...32).clamp(overlap)
            timePitchAU.overlap = overlap
        }
    }

    /// Initialize the time pitch node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    ///   - pitch: Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    ///   - overlap: Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    ///
    public init(
        _ input: AKNode,
        rate: AUValue = 1.0,
        pitch: AUValue = 0.0,
        overlap: AUValue = 8.0) {

        self.rate = rate
        self.pitch = pitch
        self.overlap = overlap

        super.init(avAudioNode: AVAudioNode())
        avAudioUnit = timePitchAU
        avAudioNode = timePitchAU

        connections.append(input)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        timePitchAU.bypass = false
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        timePitchAU.bypass = true
    }
}
