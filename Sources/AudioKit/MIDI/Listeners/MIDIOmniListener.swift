// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation
import CoreMIDI

///  This class probably needs to support observers as well
///  so that a client may be able to be notified of state changes
public class MIDIOMNIListener: NSObject {

    var omniMode: Bool

    /// Initialize with omni mode
    /// - Parameter omni: Omni mode activate
    public init(omni: Bool = true) {
        omniMode = omni
    }
}

// MARK: - MIDIOMNIListener should be used as an MIDIListener

extension MIDIOMNIListener: MIDIListener {
    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                    velocity: MIDIVelocity,
                                    channel: MIDIChannel,
                                    portID: MIDIUniqueID? = nil,
                                    timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte, channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        if controller == MIDIControl.omniModeOff.rawValue {
            guard omniMode == true else { return }
            omniMode = false
            omniStateChange()
        }
        if controller == MIDIControl.omniModeOn.rawValue {
            guard omniMode == false else { return }
            omniMode = true
            omniStateChange()
        }
    }

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                       pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - timeStamp:MIDI Event TimeStamp
    ///
    public func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - timeStamp:       MIDI Event TimeStamp
    ///
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - timeStamp:MIDI Event TimeStamp
    ///
    public func receivedMIDIProgramChange(_ program: MIDIByte,
                                          channel: MIDIChannel,
                                          portID: MIDIUniqueID? = nil,
                                          timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive a MIDI system command (such as clock, SysEx, etc)
    ///
    /// - data:       Array of integers
    /// - portID:     MIDI Unique Port ID
    /// - offset:     MIDI Event TimeStamp
    ///
    public func receivedMIDISystemCommand(_ data: [MIDIByte],
                                          portID: MIDIUniqueID? = nil,
                                          timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// MIDI Setup has changed
    public func receivedMIDISetupChange() {
        // Do nothing
    }

    /// MIDI Object Property has changed
    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    /// Generic MIDI Notification
    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }

    /// OMNI State Change - override in subclass
    public func omniStateChange() {
        // override in subclass?
    }
}

#endif
