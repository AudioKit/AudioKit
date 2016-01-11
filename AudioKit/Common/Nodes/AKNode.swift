//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKNode {
    public var avAudioNode: AVAudioNode
    public var connectionPoints = [AVAudioConnectionPoint]()

    public init() {
        self.avAudioNode = AVAudioNode()
    }
    
    public func addConnectionPoint(node: AKNode) {
        connectionPoints.append(AVAudioConnectionPoint(node: node.avAudioNode, bus: 0))
        AKManager.sharedInstance.engine.connect(avAudioNode,
            toConnectionPoints: connectionPoints,
            fromBus: 0,
            format: AKManager.format)
    }
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
