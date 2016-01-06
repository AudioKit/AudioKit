//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Mixer Node
public class AKBooster: AKNode, AKToggleable {
    private let mixer = AVAudioMixerNode()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    
    /// Amplification Factor
    public var gain: Double = 1.0 {
        didSet {
            mixer.outputVolume = Float(gain)
        }
    }
    
    private var lastKnownGain: Double = 1.0
    
    public var isStarted: Bool {
        return gain != 1.0
    }
    
    /// Initialize this amplification node
    ///
    /// - parameter input: AKNode whose output will be amplified
    /// - parameter gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(
        var _ input: AKNode,
        gain: Double = 1.0) {
            
        self.avAudioNode = mixer
        AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        input.addConnectionPoint(self)
            
        mixer.outputVolume = Float(gain)
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            gain = lastKnownGain
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownGain = gain
            gain = 0
        }
    }
}
