//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioConnectionPoint {
    convenience init(_ node: AKNode, to bus: Int) {
        self.init(node: node.avAudioNode, bus: bus)
    }
}

/// Parent class for all nodes in AudioKit
@objc open class AKNode: NSObject {
    
    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode
    
    /// An array of all connections
    internal var connectionPoints = [AVAudioConnectionPoint]()

    /// Create the node
    override public init() {
        self.avAudioNode = AVAudioNode()
    }

    public init(avAudioNode: AVAudioNode, attach: Bool = false) {
      self.avAudioNode = avAudioNode
      if attach {
        AudioKit.engine.attach(avAudioNode)
      }
    }

    /// Connect this node to another
    open func addConnectionPoint(_ node: AKNode, bus: Int = 0) {
        connectionPoints.append(AVAudioConnectionPoint(node, to: bus))
        AudioKit.engine.connect(avAudioNode,
                                to: connectionPoints,
                                fromBus: bus,
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
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    
    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    func stop(noteNumber: MIDINoteNumber)
}

/// Bare bones implementation of AKPolyphonic protocol
open class AKPolyphonicNode: AKNode, AKPolyphonic {
    
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        AKLog("Playing note \(noteNumber), with velocity \(velocity), override in subclass")
    }
    
    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
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
