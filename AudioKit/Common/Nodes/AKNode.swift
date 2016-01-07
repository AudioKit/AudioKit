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
}

public protocol AKToggleable {
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }
    
    /// Function to start, play, or activate the node, all do the same thing
    func start()
    
    /// Function to stop or bypass the node, both are equivalent
    func stop()
}

public extension AKToggleable {
    
    /// Synonym for isStarted that may make more sense with musical instruments
    public var isPlaying: Bool {
        return isStarted
    }
    
    /// Antonym for isStarted
    public var isStopped: Bool {
        return !isStarted
    }
    
    /// Antonym for isStarted that may make more sense with effects
    public var isBypassed: Bool {
        return !isStarted
    }
    
    /// Synonym to start that may more more sense with musical instruments
    public func play() {
        start()
    }
    
    /// Synonym for stop that may make more sense with effects
    public func bypass() {
        stop()
    }
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
