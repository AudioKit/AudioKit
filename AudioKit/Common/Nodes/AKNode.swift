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

/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {
    
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    
    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    func stop(noteNumber noteNumber: MIDINoteNumber)
}

/// Bare bones implementation of AKPolyphonic protocol
public class AKPolyphonicNode: AKNode, AKPolyphonic {
    
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    public func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        print("Playing note \(noteNumber), with velocity \(velocity), override in subclass")
    }
    
    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    public func stop(noteNumber noteNumber: MIDINoteNumber) {
        print("Stopping note \(noteNumber), override in subclass")
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
