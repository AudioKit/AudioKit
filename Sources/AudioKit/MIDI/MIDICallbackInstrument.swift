// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation

/// MIDI Instrument that triggers functions on MIDI note on/off commands
/// This is used mostly with the AppleSequencer sending to a MIDIEndpointRef
/// Another callback instrument, AKCallbackInstrument
/// You will need to enable "Background Modes - Audio" in your project for this to work.
open class AKMIDICallbackInstrument: AKMIDIInstrument {

    // MARK: - Properties

    /// All callbacks that will get triggered by MIDI events
    open var callback: AKMIDICallback?

    // MARK: - Initialization

    /// Initialize the callback instrument
    ///
    /// - parameter midiInputName: Name of the instrument's MIDI input
    /// - parameter callback: Initial callback
    ///
    public init(midiInputName: String = "AudioKit Callback Instrument", callback: AKMIDICallback? = nil) {
        super.init(midiInputName: midiInputName)
        self.name = midiInputName
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
    }

    // MARK: - Triggering

    fileprivate func triggerCallbacks(_ status: AKMIDIStatus,
                                      data1: MIDIByte,
                                      data2: MIDIByte) {
        _ = callback.map { $0(status.byte, data1, data2) }
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    open override func start(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .noteOn, channel: channel),
                         data1: noteNumber,
                         data2: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - channel:    MIDI Channel
    ///
    open override func stop(noteNumber: MIDINoteNumber,
                            channel: MIDIChannel,
                            offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .noteOff, channel: channel),
                         data1: noteNumber,
                         data2: 0)
    }

    // MARK: - MIDI

    open override func receivedMIDIController(_ controller: MIDIByte,
                                              value: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .controllerChange, channel: channel),
                         data1: controller,
                         data2: value)
    }

    open override func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                              pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .polyphonicAftertouch, channel: channel),
                         data1: noteNumber,
                         data2: pressure)
    }

    open override func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .channelAftertouch, channel: channel),
                         data1: pressure,
                         data2: 0)
    }

    open override func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        triggerCallbacks(AKMIDIStatus(type: .pitchWheel, channel: channel),
                         data1: pitchWheelValue.msb,
                         data2: pitchWheelValue.lsb)
    }
}

#endif
