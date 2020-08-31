// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation

/// Wrapper for audio units that accept MIDI (ie. instruments)
open class AKAudioUnitInstrument: AKMIDIInstrument {
    /// Initialize the audio unit instrument
    ///
    /// - parameter audioUnit: AVAudioUnitMIDIInstrument to wrap
    ///
    public init?(audioUnit: AVAudioUnitMIDIInstrument) {
        super.init()
        midiInstrument = audioUnit

        // assign the output to the mixer
        avAudioUnit = audioUnit
        avAudioNode = audioUnit
        name = audioUnit.name
    }

    /// Send MIDI Note On information to the audio unit
    ///
    /// - Parameters
    ///   - noteNumber: MIDI note number to play
    ///   - velocity: MIDI velocity to play the note at
    ///   - channel: MIDI channel to play the note on
    ///
    override open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 64, channel: MIDIChannel = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    /// Send MIDI Note Off information to the audio unit
    ///
    /// - Parameters
    ///   - noteNumber: MIDI note number to stop
    ///   - channel: MIDI channel to stop the note on
    ///
    override open func stop(noteNumber: MIDINoteNumber) {
        self.stop(noteNumber: noteNumber, channel: 0)
    }

    override open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel, offset: MIDITimeStamp = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.stopNote(noteNumber, onChannel: channel)
    }

    override open func receivedMIDIController(_ controller: MIDIByte,
                                              value: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.sendController(controller, withValue: value, onChannel: channel)
    }

    override open func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                              pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.sendPressure(forKey: noteNumber, withValue: pressure, onChannel: channel)
    }

    override open func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.sendPressure(pressure, onChannel: channel)
    }

    override open func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                              channel: MIDIChannel,
                                              portID: MIDIUniqueID? = nil,
                                              offset: MIDITimeStamp = 0) {
        guard let midiInstrument = midiInstrument else {
            AKLog("no midiInstrument exists", type: .error)
            return
        }
        midiInstrument.sendPitchBend(pitchWheelValue, onChannel: channel)
    }
}

#endif
