// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// AudioKit version of Apple's Reverb Audio Unit
///
public class Reverb: Node {
    fileprivate let reverbAU = AVAudioUnitReverb()

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }
    
    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Start the node
    public func start() { reverbAU.wetDryMix = dryWetMix * 100.0 }
    /// Stop the node
    public func stop() { reverbAU.wetDryMix = 0.0  }
    /// Play the node
    public func play() { reverbAU.wetDryMix = dryWetMix * 100.0 }
    /// Bypass the node
    public func bypass() { reverbAU.wetDryMix = 0.0 }

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
    ///   - input: Node to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 0.5, Range: 0 - 1)
    ///
    public init(_ input: Node, dryWetMix: AUValue = 0.5) {
        self.input = input
        self.dryWetMix = dryWetMix

        avAudioNode = reverbAU

        reverbAU.wetDryMix = dryWetMix * 100.0
    }

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }

}
