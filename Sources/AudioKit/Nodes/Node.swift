// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKIt connection point
open class Node {
    /// Nodes providing input to this node.
    var connections: [Node] = []

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
        return avAudioUnit ?? avAudioNode
    }

    /// Initialize the node from an AVAudioUnit
    /// - Parameter avAudioUnit: AVAudioUnit to initialize with
    public init(avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
    }

    /// Initialize the node from an AVAudioNode
    /// - Parameter avAudioNode: AVAudioNode to initialize with
    public init(avAudioNode: AVAudioNode) {
        self.avAudioNode = avAudioNode
    }

    /// Reset the internal state of the unit
    /// Fixes issues such as https://github.com/AudioKit/AudioKit/issues/2046
    public func reset() {
        if let avAudioUnit = self.avAudioUnit {
            AudioUnitReset(avAudioUnit.audioUnit, kAudioUnitScope_Global, 0)
        }
    }

    func detach() {
        if let engine = avAudioNode.engine {
            engine.detach(avAudioNode)
        }
        for connection in connections {
            connection.detach()
        }
    }

    func makeAVConnections() {
        // Are we attached?
        if let engine = avAudioNode.engine {
            for (bus, connection) in connections.enumerated() {
                if let sourceEngine = connection.avAudioNode.engine {
                    if sourceEngine != avAudioNode.engine {
                        Log("🛑 Error: Attempt to connect nodes from different engines.")
                        return
                    }
                }

                engine.attach(connection.avAudioNode)

                // Mixers will decide which input bus to use.
                if let mixer = avAudioNode as? AVAudioMixerNode {
                    mixer.connect(input: connection.avAudioNode, bus: mixer.nextAvailableInputBus)
                } else {
                    avAudioNode.connect(input: connection.avAudioNode, bus: bus)
                }

                connection.makeAVConnections()
            }
        }
    }

    /// Work-around for an AVAudioEngine bug.
    func initLastRenderTime() {

        // We don't have a valid lastRenderTime until we query it.
        _ = avAudioNode.lastRenderTime

        for connection in connections {
            connection.initLastRenderTime()
        }
    }
}

/// Protocol for responding to play and stop of MIDI notes
public protocol Polyphonic {
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

/// Bare bones implementation of Polyphonic protocol
open class PolyphonicNode: Node, Polyphonic {
    /// Global tuning table used by PolyphonicNode (Node classes adopting Polyphonic protocol)
    @objc public static var tuningTable = TuningTable()
    /// MIDI Instrument
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
        Log("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), channel: \(channel), " +
            "override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        // Microtonal pitch lookup

        // default implementation is 12 ET
        let frequency = PolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        play(noteNumber: noteNumber, velocity: velocity, frequency: AUValue(frequency), channel: channel)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    open func stop(noteNumber: MIDINoteNumber) {
        Log("Stopping note \(noteNumber), override in subclass")
    }
}

/// Protocol to allow nodes to be tapped using AudioKit's tapping system (not AVAudioEngine's installTap)
public protocol Tappable {
    /// Install tap on this node
    func installTap()
    /// Remove tap on this node
    func removeTap()
    /// Get the latest data for this node
    /// - Parameter sampleCount: Number of samples to retrieve
    /// - Returns: Float channel data for two channels
    func getTapData(sampleCount: Int) -> FloatChannelData
}

/// Default functions for nodes that conform to Tappable
extension Tappable where Self: AudioUnitContainer {
    /// Install tap on this node
    public func installTap() {
        akInstallTap(internalAU?.dsp)
    }
    /// Remove tap on this node
    public func removeTap() {
        akRemoveTap(internalAU?.dsp)
    }
    /// Get the latest data for this node
    /// - Parameter sampleCount: Number of samples to retrieve
    /// - Returns: Float channel data for two channels
    public func getTapData(sampleCount: Int) -> FloatChannelData {
        var leftData = [Float](repeating: 0, count: sampleCount)
        var rightData = [Float](repeating: 0, count: sampleCount)
        var success = false
        leftData.withUnsafeMutableBufferPointer { leftPtr in
            rightData.withUnsafeMutableBufferPointer { rightPtr in
                success = akGetTapData(internalAU?.dsp, sampleCount, leftPtr.baseAddress!, rightPtr.baseAddress!)
            }
        }
        if !success { return [] }
        return [leftData, rightData]
    }
}

/// Protocol for dictating that a node can be in a started or stopped state
public protocol Toggleable {
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }

    /// Function to start, play, or activate the node, all do the same thing
    func start()

    /// Function to stop or bypass the node, both are equivalent
    func stop()
}

/// Default functions for nodes that conform to Toggleable
public extension Toggleable {
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

public extension Toggleable where Self: AudioUnitContainer {
    /// Is node started?
    var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    /// Start node
    func start() {
        internalAU?.start()
    }

    /// Stop node
    func stop() {
        internalAU?.stop()
    }
}
