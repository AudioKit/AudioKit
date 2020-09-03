// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

open class AKNode {

    /// Nodes providing input to this node.
    var connections: [AKNode] = []

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// The internal AVAudioUnit, which is a subclass of AVAudioNode with more capabilities
    open var avAudioUnit: AVAudioUnit? {
        didSet {
            guard let avAudioUnit = avAudioUnit else { return }

            let mirror = Mirror(reflecting: self)

            for child in mirror.children {
                if let param = child.value as? ParameterBase, let label = child.label {
                    // Property wrappers create a variable with an underscore
                    // prepended. Drop the underscore to look up the parameter.
                    let name = String(label.dropFirst())
                    param.projectedValue.associate(with: avAudioUnit,
                                                   identifier: name)
                }
            }
        }
    }

    /// Returns either the avAudioUnit or avAudioNode (prefers the avAudioUnit if it exists)
    open var avAudioUnitOrNode: AVAudioNode {
        return self.avAudioUnit ?? self.avAudioNode
    }

    /// Initialize the node from an AVAudioUnit
    public init(avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
    }

    /// Initialize the node from an AVAudioNode
    public init(avAudioNode: AVAudioNode) {
        self.avAudioNode = avAudioNode
    }

    deinit {
        detach()
    }

    public func detach() {
        if let engine = self.avAudioNode.engine {
            engine.detach(self.avAudioNode)
        }
    }

    func makeAVConnections() {
        // Are we attached?
        if let engine = self.avAudioNode.engine {
            for connection in connections {
                if let sourceEngine = connection.avAudioNode.engine {
                    if sourceEngine != avAudioNode.engine {
                        AKLog("error: Attempt to connect nodes from different engines.")
                        return
                    }
                }
                engine.attach(connection.avAudioNode)
                engine.connect(connection.avAudioNode, to: avAudioNode)
                connection.makeAVConnections()
            }
        }
    }

    public func connect(node: AKNode) {
        if avAudioNode.numberOfInputs == 0 {
            AKLog("error: Node has no input buses.")
            return
        }
        if node.avAudioNode.numberOfOutputs == 0 {
            AKLog("error: Node has no output buses.")
            return
        }
        if connections.contains(where: { $0 === node }) {
            AKLog("error: Node is already connected.")
            return
        }
        if let engine = avAudioNode.engine {
            if engine.isRunning && ((avAudioNode as? AVAudioMixerNode) == nil) {
                AKLog("error: connections may only be made to mixers while the engine is running.")
                return
            }
        }
        connections.append(node)
        makeAVConnections()
    }

    public func connect(to nodes: [AKNode]) {
        for node in nodes { connect(node: node) }
    }

    public func disconnect(node: AKNode) {
        connections.removeAll(where: { $0 === node })
        avAudioNode.disconnect(input: node.avAudioNode)
    }

}

// Set output connection(s)
infix operator >>>: AdditionPrecedence

@discardableResult public func >>> (left: AKNode, right: AKNode) -> AKNode {
    right.connect(node: left)
    return right
}


/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: AUValue, channel: MIDIChannel)

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
open class AKPolyphonicNode: AKNode, AKPolyphonic {
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
    open func play(noteNumber: MIDINoteNumber,
                   velocity: MIDIVelocity,
                   frequency: AUValue,
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
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        // MARK: Microtonal pitch lookup

        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: AUValue(frequency), channel: channel)
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

public extension AKToggleable where Self: AKComponent {

    var isStarted: Bool {
        return (internalAU as? AKAudioUnitBase)?.isStarted ?? false
    }

    func start() {
        (internalAU as? AKAudioUnitBase)?.start()
    }

    func stop() {
        (internalAU as? AKAudioUnitBase)?.stop()
    }
}
