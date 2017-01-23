//
//  AKMIDIListener.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Protocol that must be adhered to if you want your class to respond to MIDI
///
/// Implement the AKMIDIListener protocol on any classes that need to respond
/// to incoming MIDI events.  Every method in the protocol is optional to allow
/// the classes complete freedom to respond to only the particular MIDI messages
/// of interest.
///
public protocol AKMIDIListener {
    
    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel)
    
    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel)
    
    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel)
    
    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: Int,
                                channel: MIDIChannel)
    
    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIAfterTouch(_ pressure: Int, channel: MIDIChannel)
    
    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///
    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: MIDIChannel)
    
    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIProgramChange(_ program: Int, channel: MIDIChannel)
    
    /// Receive a midi system command (such as clock, sysex, etc)
    ///
    /// - parameter data: Array of integers
    ///
    func receivedMIDISystemCommand(_ data: [MIDIByte])
    
    /// MIDI Setup has changed
    func receivedMIDISetupChange()
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
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        AKLog("channel: \(channel) noteOn: \(noteNumber) velocity: \(velocity)")
    }
    
    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel) {
        AKLog("channel: \(channel) noteOff: \(noteNumber) velocity: \(velocity)")
    }
    
    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel) {
        AKLog("channel: \(channel) controller: \(controller) value: \(value)")
    }
    
    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: Int,
                                channel: MIDIChannel) {
        AKLog("channel: \(channel) midiAftertouch Note: \(noteNumber) pressure: \(pressure)")
    }
    
    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIAfterTouch(_ pressure: Int, channel: MIDIChannel) {
        AKLog("channel: \(channel) midiAfterTouch pressure: \(pressure)")
    }
    
    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///
    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: MIDIChannel) {
        AKLog("channel: \(channel) pitchWheel: \(pitchWheelValue)")
    }
    
    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    func receivedMIDIProgramChange(_ program: Int, channel: MIDIChannel) {
        AKLog("channel: \(channel) programChange: \(program)")
    }
    
    /// Receive a midi system command (such as clock, sysex, etc)
    ///
    /// - parameter data: Array of integers
    ///
    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        AKLog("MIDI System Command: \(AKMIDISystemCommand(rawValue: data[0])!)")
    }
    
    /// MIDI Setup has changed
    func receivedMIDISetupChange() {
        AKLog("MIDI Setup Has Changed.")
    }
    
}
