//
//  AKMIDIListener.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/** Implement the AKMIDIListener protocol on any classes that need to respond
to incoming MIDI events.  Every method in the protocol is optional to allow
the classes complete freedom to respond to only the particular MIDI messages
of interest.
*/

import Foundation

/// Protocol that must be adhered to if you want your class to respond to MIDI
public protocol AKMIDIListener {

    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOn(noteNumber noteNumber: MIDINoteNumber,
                                       velocity: MIDIVelocity,
                                       channel: Int)

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOff(noteNumber noteNumber: MIDINoteNumber,
                                        velocity: MIDIVelocity,
                                        channel: Int)

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIController(controller: Int, value: Int, channel: Int)

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIAftertouch(noteNumber noteNumber: MIDINoteNumber,
                                           pressure: Int,
                                           channel: Int)

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIAfterTouch(pressure: Int, channel: Int)

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///
    func receivedMIDIPitchWheel(pitchWheelValue: Int, channel: Int)

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIProgramChange(program: Int, channel: Int)

    /// Receive a midi system command (such as clock, sysex, etc)
    ///
    /// - parameter data: Array of integers
    ///
    func receivedMIDISystemCommand(data: [UInt8])
}

/// Default listener functions
public extension AKMIDIListener {

    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOn(noteNumber noteNumber: MIDINoteNumber,
                                       velocity: MIDIVelocity,
                                       channel: Int) {
        print("channel: \(channel) noteOn: \(noteNumber) velocity: \(velocity)")
    }

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOff(noteNumber noteNumber: MIDINoteNumber,
                                        velocity: MIDIVelocity,
                                        channel: Int) {
        print("channel: \(channel) noteOff: \(noteNumber) velocity: \(velocity)")
    }

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIController(controller: Int, value: Int, channel: Int) {
        print("channel: \(channel) controller: \(controller) value: \(value)")
    }

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIAftertouch(noteNumber noteNumber: MIDINoteNumber,
                                           pressure: Int,
                                           channel: Int) {
        print("channel: \(channel) midiAftertouch Note: \(noteNumber) pressure: \(pressure)")
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIAfterTouch(pressure: Int, channel: Int) {
        print("channel: \(channel) midiAfterTouch pressure: \(pressure)")
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///
    func receivedMIDIPitchWheel(pitchWheelValue: Int, channel: Int) {
        print("channel: \(channel) pitchWheelC: \(pitchWheelValue)")
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIProgramChange(program: Int, channel: Int) {
        print("channel: \(channel) programChange: \(program)")
    }

    /// Receive a midi system command (such as clock, sysex, etc)
    ///
    /// - parameter data: Array of integers
    ///
    func receivedMIDISystemCommand(data: [UInt8]) {
        print("MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!)")
    }
}
