// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation

/// Function type for MIDI callbacks
public typealias MIDICallback = (MIDIByte, MIDIByte, MIDIByte) -> Void

/// MIDI Instrument that triggers functions on MIDI note on/off commands
/// This is used mostly with the AppleSequencer sending to a MIDIEndpointRef
/// Another callback instrument, CallbackInstrument
/// You will need to enable "Background Modes - Audio" in your project for this to work.
open class MIDICallbackInstrument: MIDIInstrument {

    // MARK: - Properties

    /// All callbacks that will get triggered by MIDI events
    open var callback: MIDICallback?

    // MARK: - Initialization

    /// Initialize the callback instrument
    ///
    /// - parameter midiInputName: Name of the instrument's MIDI input
    /// - parameter callback: Initial callback
    ///
    public init(midiInputName: String = "AudioKit Callback Instrument", callback: MIDICallback? = nil) {
        super.init(midiInputName: midiInputName)
        self.name = midiInputName
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
    }

    // MARK: - Triggering

    fileprivate func triggerCallbacks(_ status: MIDIStatus,
                                      data1: MIDIByte,
                                      data2: MIDIByte) {
        callback?(status.byte, data1, data2)
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity: MIDI Velocity (0-127)
    ///   - channel: MIDI Channel
    ///
    open override func start(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .noteOn, channel: channel),
                         data1: noteNumber,
                         data2: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - channel: MIDI Channel
    ///   - offset: MIDI Timestamp
    ///
    open override func stop(noteNumber: MIDINoteNumber,
                            channel: MIDIChannel,
                            timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .noteOff, channel: channel),
                         data1: noteNumber,
                         data2: 0)
    }

    // MARK: - MIDI

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    open override func receivedMIDIController(_ controller: MIDIByte,
                                              value: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .controllerChange, channel: channel),
                         data1: controller,
                         data2: value)
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
    open override func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                              pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .polyphonicAftertouch, channel: channel),
                         data1: noteNumber,
                         data2: pressure)
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - timeStamp:MIDI Event TimeStamp
    ///
    open override func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .channelAftertouch, channel: channel),
                         data1: pressure,
                         data2: 0)
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - timeStamp:       MIDI Event TimeStamp
    ///
    open override func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              timeStamp: MIDITimeStamp? = nil) {
        triggerCallbacks(MIDIStatus(type: .pitchWheel, channel: channel),
                         data1: pitchWheelValue.msb,
                         data2: pitchWheelValue.lsb)
    }
    
}

#endif
