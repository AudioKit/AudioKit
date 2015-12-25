//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Mixer Node */
public struct AKMixer: AKNode {
    private let mixerAU = AVAudioMixerNode()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
        
    /** Output Volume (Default 1) */
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixerAU.outputVolume = Float(volume)
        }
    }
    
    /** Initialize the mixer node 
     
     - parameter inputs: A varaiadic list of AKNodes
     */
    public init(_ inputs: AKNode...) {
        self.avAudioNode = mixerAU
        AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        for input in inputs {
            connect(input)
        }
    }
    
    /** Connnect another input after initialization

     - parameter input: AKNode to connect
     */
    public func connect(input: AKNode) {
        AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
    }
}
