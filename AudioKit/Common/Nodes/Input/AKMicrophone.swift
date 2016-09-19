//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio from the standard input
open class AKMicrophone: AKNode, AKToggleable {
    
    internal let mixer = AVAudioMixerNode()
    
    /// Output Volume (Default 1)
    open var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixer.outputVolume = Float(volume)
        }
    }
    
    fileprivate var lastKnownVolume: Double = 1.0
    
    /// Determine if the microphone is currently on.
    open var isStarted: Bool {
        return volume != 0.0
    }
    
    /// Initialize the microphone 
    override public init() {
        #if !os(tvOS)
            super.init()
            self.avAudioNode = mixer
            AKSettings.audioInputEnabled = true
            AudioKit.engine.attach(mixer)
            AudioKit.engine.connect(AudioKit.engine.inputNode!, to: self.avAudioNode, format: nil)
        #endif
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }
}
