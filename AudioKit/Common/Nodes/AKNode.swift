//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AVAudioConnectionPoint {
    convenience init(_ node: AKNode, to bus: Int) {
        self.init(node: node.avAudioUnitOrNode, bus: bus)
    }
}

/// Parent class for all nodes in AudioKit
@objc open class AKNode: NSObject {
    /// The internal AVAudioEngine AVAudioNode
    @objc open var avAudioNode: AVAudioNode

    /// The internal AVAudioUnit, which is a subclass of AVAudioNode with more capabilities
    @objc open var avAudioUnit: AVAudioUnit?

    /// Returns either the avAudioUnit (preferred
    @objc open var avAudioUnitOrNode: AVAudioNode {
        return self.avAudioUnit ?? self.avAudioNode
    }

    /// Create the node
    public override init() {
        self.avAudioNode = AVAudioNode()
    }

    /// Initialize the node from an AVAudioUnit
    @objc public init(avAudioUnit: AVAudioUnit, attach: Bool = false) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
        if attach {
            AKManager.engine.attach(avAudioUnit)
        }
    }

    /// Initialize the node from an AVAudioNode
    @objc public init(avAudioNode: AVAudioNode, attach: Bool = false) {
        self.avAudioNode = avAudioNode
        if attach {
            AKManager.engine.attach(avAudioNode)
        }
    }

    // Subclasses should override to detach all internal nodes
    open func detach() {
        AKManager.detach(nodes: [avAudioUnitOrNode])
    }
}

extension AKNode: AKOutput {
    public var outputNode: AVAudioNode {
        return self.avAudioUnitOrNode
    }

    @available(*, deprecated, renamed: "connect(to:bus:)")
    open func addConnectionPoint(_ node: AKNode, bus: Int = 0) {
        connectionPoints.append(AVAudioConnectionPoint(node, to: bus))
    }
}

// Deprecated
extension AKNode {
    @objc @available(*, deprecated, renamed: "detach")
    open func disconnect() {
        self.detach()
    }

    @available(*, deprecated, message: "Use AudioKit.detach(nodes:) instead")
    open func disconnect(nodes: [AVAudioNode]) {
        AKManager.detach(nodes: nodes)
    }
}

/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double, channel: MIDIChannel)

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    func stop(noteNumber: MIDINoteNumber)
}

/// Bare bones implementation of AKPolyphonic protocol
@objc open class AKPolyphonicNode: AKNode, AKPolyphonic {
    /// Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    @objc public static var tuningTable = AKTuningTable()
    open var midiInstrument: AVAudioUnitMIDIInstrument?

    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    ///
    @objc open func play(noteNumber: MIDINoteNumber,
                         velocity: MIDIVelocity,
                         frequency: Double,
                         channel: MIDIChannel = 0) {
        AKLog("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), channel: \(channel), " +
            "override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    @objc open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        // MARK: Microtonal pitch lookup

        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        //        AKLog("Playing note: \(noteNumber), velocity: \(velocity), using tuning table frequency: \(frequency)")
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: frequency, channel: channel)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    @objc open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
    }

    deinit {
        detach()
    }
}

/// Protocol for dictating that a node can be in a started or stopped state
@objc public protocol AKToggleable {
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
    var isPlaying: Bool {
        return isStarted
    }

    /// Antonym for isStarted
    var isStopped: Bool {
        return !isStarted
    }

    /// Antonym for isStarted that may make more sense with effects
    var isBypassed: Bool {
        return !isStarted
    }

    /// Synonym to start that may more more sense with musical instruments
    func play() {
        start()
    }

    /// Synonym for stop that may make more sense with effects
    func bypass() {
        stop()
    }
}
