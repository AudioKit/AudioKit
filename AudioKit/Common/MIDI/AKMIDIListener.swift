//
//  AKMIDIListener.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Protocol that must be adhered to if you want your class to respond to MIDI
///
/// Implement the AKMIDIListener protocol on any classes that need to respond
/// to incoming MIDI events.  Every method in the protocol is optional to allow
/// the classes complete freedom to respond to only the particular MIDI messages
/// of interest.
///

let AKMIDIListenerLogging = false

public protocol AKMIDIListener {

    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            offset: MIDITimeStamp)

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             offset: MIDITimeStamp)

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp)

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp)

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp)

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - offset:          the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                offset: MIDITimeStamp)

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
  func receivedMIDIProgramChange(_ program: MIDIByte,
                                 channel: MIDIChannel,
                                 portID: MIDIUniqueID?,
                                 offset: MIDITimeStamp)

    /// Receive a MIDI system command (such as clock, sysex, etc)
    ///
    /// - data:       Array of integers
    /// - portID:     MIDI Unique Port ID
    /// - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID?,
                                   offset: MIDITimeStamp)

    /// MIDI Setup has changed
    func receivedMIDISetupChange()

    /// MIDI Object Property has changed
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification)

    /// Generic MIDI Notification
    func receivedMIDINotification(notification: MIDINotification)
}

/// Default listener functions
public extension AKMIDIListener {

    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("channel: \(channel) noteOn: \(noteNumber) velocity: \(velocity) port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("channel: \(channel) noteOff: \(noteNumber) velocity: \(velocity) port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("channel: \(channel) controller: \(controller) value: \(value) " +
                "port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("channel: \(channel) MIDI Aftertouch Note: \(noteNumber) " +
                "pressure: \(pressure) port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
  func receivedMIDIAftertouch(_ pressure: MIDIByte,
                              channel: MIDIChannel,
                              portID: MIDIUniqueID? = nil,
                              offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("channel: \(channel) MIDI Aftertouch pressure: \(pressure) " +
                "port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - offset:          the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
          AKLog("channel: \(channel) pitchWheel: \(pitchWheelValue) port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
          AKLog("channel: \(channel) programChange: \(program) port: \(portID ?? 0) offset: \(offset)", log: OSLog.midi)
        }
    }

    /// Receive a MIDI system command (such as clock, sysex, etc)
    ///
    /// - Parameters:
    /// - data:   Array of integers
    /// - portID: MIDI Unique Port ID
    /// - offset: the offset in samples that this event occurs in the buffer
    ///
    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        if AKMIDIListenerLogging {
            AKLog("AKMIDIListener default method", log: OSLog.midi)
        }
    }

    /// MIDI Setup has changed
    func receivedMIDISetupChange() {
        if AKMIDIListenerLogging {
            AKLog("MIDI Setup Has Changed.", log: OSLog.midi)
        }
    }

    /// MIDI Setup has changed
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        AKLog("MIDI Property Has Changed.", log: OSLog.midi)
    }

    /// Generic MIDI Notification
    func receivedMIDINotification(notification: MIDINotification) {
        AKLog("MIDI Notification received.", log: OSLog.midi)
    }

    func isEqualTo(_ listener: AKMIDIListener) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIListener, rhs: AKMIDIListener) -> Bool {
    return lhs.isEqualTo(rhs)
}
