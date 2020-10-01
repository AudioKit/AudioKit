// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import AVFoundation
import CoreAudio

/// A version of Instrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class MIDINode: Node, MIDIListener {

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "MIDINode"

    private var internalNode: PolyphonicNode

    // MARK: - Initialization

    /// Initialize the MIDI node
    ///
    /// - parameter node: A polyphonic node that will be triggered via MIDI
    /// - parameter midiOutputName: Name of the node's MIDI output
    ///
    public init(node: PolyphonicNode, midiOutputName: String? = nil) {
        internalNode = node
        super.init(avAudioNode: AVAudioNode())
        avAudioNode = internalNode.avAudioNode
        avAudioUnit = internalNode.avAudioUnit
      enableMIDI(name: midiOutputName ?? "Unnamed")
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef = MIDI.sharedInstance.client,
                           name: String = "Unnamed") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = MIDIEvent(packet: e)
                guard event.data.count > 2 else {
                    return
                }
                self.handleMIDI(data1: event.data[0],
                                data2: event.data[1],
                                data3: event.data[2])

            }
        })
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = MIDIStatus(byte: data1)
        let channel = status?.channel
        let noteNumber = MIDINoteNumber(data2)
        let velocity = MIDIVelocity(data3)

        if status?.type == .noteOn && velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel ?? 0)
        } else if status?.type == .noteOn && velocity == 0 {
            internalNode.stop(noteNumber: noteNumber)
        } else if status?.type == .noteOff {
            internalNode.stop(noteNumber: noteNumber)
        }
    }

    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   offset: MIDITimeStamp) {
        if velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            internalNode.stop(noteNumber: noteNumber)
        }
    }


    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                    velocity: MIDIVelocity,
                                    channel: MIDIChannel,
                                    portID: MIDIUniqueID?,
                                    offset: MIDITimeStamp) {
        // Do nothing
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
    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte, channel: MIDIChannel,
                                       portID: MIDIUniqueID?,
                                       offset: MIDITimeStamp) {
        // Do nothing
    }

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - offset:     the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                       pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID?,
                                       offset: MIDITimeStamp) {
        // Do nothing
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID?,
                                       offset: MIDITimeStamp) {
        // Do nothing
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - offset:          the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID?,
                                       offset: MIDITimeStamp) {
        // Do nothing
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - offset:   the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDIProgramChange(_ program: MIDIByte,
                                          channel: MIDIChannel,
                                          portID: MIDIUniqueID?,
                                          offset: MIDITimeStamp) {
        // Do nothing
    }

    /// Receive a MIDI system command (such as clock, SysEx, etc)
    ///
    /// - data:       Array of integers
    /// - portID:     MIDI Unique Port ID
    /// - offset:     the offset in samples that this event occurs in the buffer
    ///
    public func receivedMIDISystemCommand(_ data: [MIDIByte],
                                          portID: MIDIUniqueID?,
                                          offset: MIDITimeStamp) {
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
