// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Reverb Audio Unit
///
public class AKReverb: AKNode, AKToggleable {
    fileprivate let reverbAU = AVAudioUnitReverb()

    fileprivate var lastKnownMix: AUValue = 0.5

    /// Dry/Wet Mix (Default 0.5)
    public var dryWetMix: AUValue = 0.5 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            reverbAU.wetDryMix = dryWetMix * 100.0
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: AKNode to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 0.5, Range: 0 - 1)
    ///
    public init(_ input: AKNode, dryWetMix: AUValue = 0.5) {
        self.dryWetMix = dryWetMix
        super.init(avAudioNode: AVAudioNode())

        avAudioUnit = reverbAU
        avAudioNode = reverbAU

        connections.append(input)

        reverbAU.wetDryMix = dryWetMix * 100.0
    }

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
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
