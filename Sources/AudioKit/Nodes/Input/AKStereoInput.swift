// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Audio from a standard stereo input (very useful for making filters that use Audiobus or IAA as their input source)
public class AKStereoInput: AKNode, AKToggleable {

    internal let mixer = AVAudioMixerNode()

    /// Output Volume (Default 1)
    public var volume: AUValue = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixer.outputVolume = volume
        }
    }

    fileprivate var lastKnownVolume: AUValue = 1.0

    /// Determine if the microphone is currently on.
    public var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
    public init(volume: AUValue = 0.0) {
        super.init(avAudioNode: AVAudioNode())
        self.avAudioNode = mixer

        #if !os(tvOS)
        AKSettings.audioInputEnabled = true
//        engine.inputNode.connect(to: self.avAudioNode)
        #endif

        self.volume = volume
    }

    deinit {
        AKSettings.audioInputEnabled = false
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }
}
