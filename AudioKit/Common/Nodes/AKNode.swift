//
//  AKNode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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

    deinit {
        //AKLog("* AKNode")
        AudioKit.engine.detach(self.avAudioNode)
    }
}

/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {

    //TODO: Aure:
    
    // 2 Major approaches: 
    // 1) Expose global Swift tuning table to C++ (see comment in AKFMOscillatorBankDSPKernel.hpp)
    // 2) Pass frequency from global Swift tuning table through AKPolyphonic down to C++.
    
    //I implemented (2) for AKMorphingOscillatorBank:
    //- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
    //- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
    //- (void)stopNote:(uint8_t)note;
    
    
    // classes that would certainly benefit from [not yet implemented]:
    //AKMorphingOscillatorBankAudioUnit
    //AKClarinetAudioUnit
    //AKFluteAudioUnit
    //AKFMOscillatorAudioUnit
    //AKFMOscillatorBankAudioUnit
    //AKMandolinAudioUnit
    //AKOscillatorAudioUnit
    //AKOscillatorBankAudioUnit
    //AKPhaseDistortionOscillatorAudioUnit
    //AKPhaseDistortionOscillatorBankAudioUnit
    //AKPluckedStringAudioUnit
    //AKPWMOscillatorAudioUnit
    //AKPWMOscillatorBankAudioUnit
        

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency: play this frequency
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Float)

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

    // Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    open static var tuningTable = AKTuningTable()
    
    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency: play this frequency
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Float) {
        AKLog("Playing note:\(noteNumber), velocity:\(velocity), frequency:\(frequency), override in subclass")
    }
    
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

        // MARK: Microtonal pitch lookup
        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        AKLog("Playing note:\(noteNumber), velocity:\(velocity), using tuning table frequency:\(frequency)")
        self.play(noteNumber: noteNumber, velocity:velocity, frequency:Float(frequency))
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
