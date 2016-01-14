//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio from the standard input
public class AKMicrophone: AKNode, AKToggleable {
    
    internal let mixer = AVAudioMixerNode()
    
    /// Output Volume (Default 1)
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixer.outputVolume = Float(volume)
        }
    }
    
    private var lastKnownVolume: Double = 1.0
    
    /// Determine if the microphone is currently on.
    public var isStarted: Bool {
        return volume != 0.0
    }
    
    /// Initialize the microphone 
    public override init() {
        #if !os(tvOS)
            super.init()
            self.avAudioNode = mixer
            AKManager.sharedInstance.engine.attachNode(mixer)
            AKManager.sharedInstance.engine.connect(AKManager.sharedInstance.engine.inputNode!, to: self.avAudioNode, format: nil)
        #endif
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
