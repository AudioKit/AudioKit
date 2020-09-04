// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's VariSpeed Audio Unit
///
public class AKVariSpeed: AKNode, AKToggleable {

    fileprivate let variSpeedAU = AVAudioUnitVarispeed()

    /// Rate (rate) ranges form 0.25 to 4.0 (Default: 1.0)
    public var rate: AUValue = 1.0 {
        didSet {
            rate = (0.25...4).clamp(rate)
            variSpeedAU.rate = rate
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return rate != 1.0
    }

    fileprivate var lastKnownRate: AUValue = 1.0

    /// Initialize the varispeed node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
    ///
    public init(_ input: AKNode, rate: AUValue = 1.0) {
        self.rate = rate
        lastKnownRate = rate

        super.init(avAudioNode: AVAudioNode())
        avAudioUnit = variSpeedAU
        avAudioNode = variSpeedAU

        connections.append(input)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        rate = lastKnownRate
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        lastKnownRate = rate
        rate = 1.0
    }

    // TODO This node is untested
}
