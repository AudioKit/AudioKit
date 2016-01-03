//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Protocol for all AudioKit Nodes
public protocol AKNode {
    
    /// Output of the node 
    var avAudioNode: AVAudioNode { get set }
    
    /// Array of all connection points (effectively split output signal)
    var connectionPoints: [AVAudioConnectionPoint] { get set }

//    /// Tells whether the node is processing (ie. started, playing, or active)
//    var isStarted: Bool { get }
//
//    /// Tells whether the node is processing (ie. started, playing, or active)
//    var isPlaying: Bool { get }
//    
//    /// Tells whether the node is not processing (ie. stopped or bypassed)
//    var isStopped: Bool { get }
//
//    /// Tells whether the node is not processing (ie. stopped or bypassed)
//    var isBypassed: Bool { get }
//    
//    /// Function to start, play, or activate the node, all do the same thing
//    func start()
//    
//    /// Function to start, play, or activate the node, all do the same thing
//    func play()
//    
//    /// Function to stop or bypass the node, both are equivalent
//    func stop()
//
//    /// Function to stop or bypass the node, both are equivalent
//    func bypass()
    
}

public extension AKNode {
    public mutating func addConnectionPoint(node: AKNode) {
        connectionPoints.append(AVAudioConnectionPoint(node: node.avAudioNode, bus: 0))
        AKManager.sharedInstance.engine.connect(avAudioNode,
            toConnectionPoints: connectionPoints,
            fromBus: 0,
            format: AKManager.format)
    }
}
