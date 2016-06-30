//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Parent class for all nodes in AudioKit
@objc public class AKNode: NSObject {
    
    /// The internal AVAudioEngine AVAudioNode
    public var avAudioNode: AVAudioNode
    
    /// An array of all connections
    internal var connectionPoints = [AVAudioConnectionPoint]()

    /// Create the node
    override public init() {
        self.avAudioNode = AVAudioNode()
    }
    
    /// Connect this node to another
    public func addConnectionPoint(node: AKNode) {
        connectionPoints.append(AVAudioConnectionPoint(node: node.avAudioNode, bus: 0))
        AudioKit.engine.connect(avAudioNode,
            toConnectionPoints: connectionPoints,
            fromBus: 0,
            format: AudioKit.format)
    }
}

public protocol AKPolyphonic {
    func play(note note: Int, velocity: MIDIVelocity)
    func stop(note note: Int)
}

public class AKPolyphonicNode: AKNode, AKPolyphonic {
    public func play(note note: Int, velocity: MIDIVelocity) {
        print("Playing note \(note), with velocity \(velocity), override in subclass")
    }
    
    public func stop(note note: Int) {
        print("Stopping note \(note), override in subclass")
    }
}


/// Protocol for dictating that a node can be in a started or stopped state
public protocol AKToggleable {
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }
    
    /// Function to start, play, or activate the node, all do the same thing
    func start()
    
    /// Function to stop or bypass the node, both are equivalent
    func stop()
}

/// Default functions for nodes that conform to AKToggleable
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
