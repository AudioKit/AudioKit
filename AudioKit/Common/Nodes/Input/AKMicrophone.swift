//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio from the standard input
public struct AKMicrophone: AKNode {
    
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
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
    
    /// Initialize the microphone 
    public init() {
        #if !os(tvOS)
            self.avAudioNode = mixer
            AKManager.sharedInstance.engine.attachNode(mixer)
            AKManager.sharedInstance.engine.connect(AKManager.sharedInstance.engine.inputNode!, to: self.avAudioNode, format: nil)
        #endif
    }
}
