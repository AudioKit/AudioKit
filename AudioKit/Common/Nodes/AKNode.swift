//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AVAudioConnectionPoint {
    convenience init(_ node: AKNode, to bus: Int) {
        self.init(node: node.avAudioNode, bus: bus)
    }
}

/// Parent class for all nodes in AudioKit
@objc open class AKNode: NSObject {

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// Create the node
    override public init() {
        self.avAudioNode = AVAudioNode()
    }

    /// Initialize the node
    @objc public init(avAudioNode: AVAudioNode, attach: Bool = false) {
        self.avAudioNode = avAudioNode
        if attach {
            AudioKit.engine.attach(avAudioNode)
        }
    }
    //Subclasses should override to detach all internal nodes
    open func detach() {
        AudioKit.detach(nodes: [avAudioNode])
    }
}

extension AKNode: AKOutput {
    public var outputNode: AVAudioNode {
        return avAudioNode
    }

    @available(*, deprecated, renamed: "connect(to:bus:)")
    open func addConnectionPoint(_ node: AKNode, bus: Int = 0) {
        connectionPoints.append(AVAudioConnectionPoint(node, to: bus))
    }
}

//Deprecated
extension AKNode {

    @objc @available(*, deprecated, renamed: "detach")
    open func disconnect() {
        detach()
    }

    @available(*, deprecated, message: "Use AudioKit.dettach(nodes:) instead")
    open func disconnect(nodes: [AVAudioNode]) {
        AudioKit.detach(nodes: nodes)
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
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double)

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
@objc open class AKPolyphonicNode: AKNode, AKPolyphonic {

    /// Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    @objc open static var tuningTable = AKTuningTable()
    open var midiInstrument: AVAudioUnitMIDIInstrument?

    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    ///
    @objc open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        AKLog("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    @objc open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

        // MARK: Microtonal pitch lookup
        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        //        AKLog("Playing note: \(noteNumber), velocity: \(velocity), using tuning table frequency: \(frequency)")
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: frequency)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    @objc open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
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
