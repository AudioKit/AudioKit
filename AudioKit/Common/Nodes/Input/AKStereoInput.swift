//
//  AKStereoInput.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Audio from a standard stereo input (very useful for making filters that use Audiobus or IAA as their input source)
@objc open class AKStereoInput: AKNode, AKToggleable {

    internal let mixer = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixer.outputVolume = Float(volume)
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the microphone is currently on.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
    override public init() {
        super.init()
        self.avAudioNode = mixer

        #if !os(tvOS)
        AKSettings.audioInputEnabled = true
        AKManager.engine.inputNode.connect(to: self.avAudioNode)
        #endif
    }

    deinit {
        AKSettings.audioInputEnabled = false
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }
}
