//
//  AKMidiListener.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/** Implement the AKMidiListener protocol on any classes that need to respond
to incoming MIDI events.  Every method in the protocol is optional to allow
the classes complete freedom to respond to only the particular MIDI messages
of interest.
*/

import Foundation

public protocol AKMIDIListener{
    
    /// Receive the MIDI note on event
    /// @param note     Note number of activated note
    /// @param velocity MIDI Velocity (0-127)
    /// @param channel  MIDI Channel (1-16)
    func midiNoteOn(note:Int, velocity:Int, channel:Int)
    
    /// Receive the MIDI note off event
    /// @param note     Note number of released note
    /// @param velocity MIDI Velocity (0-127) usually speed of release, often 0.
    /// @param channel  MIDI Channel (1-16)
    func midiNoteOff(note:Int, velocity:Int, channel:Int)
    
    /// Receive single note based aftertouch event
    /// @param note     Note number of touched note
    /// @param pressure Pressure applied to the note (0-127)
    /// @param channel  MIDI Channel (1-16)
    func midiAftertouchOnNote(note:Int, pressure:Int, channel:Int)
    
    /// Receive a generic controller value
    /// @param controller MIDI Controller Number
    /// @param value      Value of this controller
    /// @param channel    MIDI Channel (1-16)
    func midiController(controller:Int, value:Int, channel:Int)
    
    /// Receive global aftertouch
    /// @param pressure Pressure applied (0-127)
    /// @param channel  MIDI Channel (1-16)
    func midiAfterTouch(pressure:Int, channel:Int)
    
    /// Receive pitch wheel value
    /// @param pitchWheelValue MIDI Pitch Wheel Value (0-127)
    /// @param channel         MIDI Channel (1-16)
    func midiPitchWheel(pitchWheelValue:Int, channel:Int)
    
    /// Receive program change
    /// @param program  MIDI Program Value (0-127)
    /// @param channel  MIDI Channel (1-16)
    func midiProgramChange(program:Int, channel:Int)
    
}

public extension AKMIDIListener{
    func midiNoteOn(note:Int, velocity:Int, channel:Int){
        print("channel: \(channel) noteOn: \(note) velocity: \(velocity)")
    }
    
    func midiNoteOff(note:Int, velocity:Int, channel:Int){
        print("channel: \(channel) noteOff: \(note) velocity: \(velocity)")
    }
    
    func midiController(controller:Int, value:Int, channel:Int){
        print("channel: \(channel) controller: \(controller) value: \(value)")
    }
    
    func midiAftertouchOnNote(note:Int, pressure:Int, channel:Int){
        print("channel: \(channel) midiAftertouchOnNote: \(note) pressure: \(pressure)")
    }
    
    func midiAfterTouch(pressure:Int, channel:Int){
        print("channel: \(channel) midiAfterTouch pressure: \(pressure)")
    }
    
    func midiPitchWheel(pitchWheelValue:Int, channel:Int){
        print("channel: \(channel) pitchWheel: \(pitchWheelValue)")
    }
    
    func midiProgramChange(program:Int, channel:Int){
        print("channel: \(channel) programChange: \(program)")
    }
}