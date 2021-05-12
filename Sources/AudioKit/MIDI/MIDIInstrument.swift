// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CoreAudio

#if !os(tvOS)

/// A version of Instrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class MIDIInstrument: Node, MIDIListener, NamedNode {

    /// Connected nodes
    public var connections: [Node] { [] }

    /// The internal AVAudioEngine AVAudioNode
    public var avAudioNode: AVAudioNode

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "(unset)"

    /// Active MPE notes
    open var mpeActiveNotes: [(note: MIDINoteNumber, channel: MIDIChannel)] = []

    /// Initialize the MIDI Instrument
    ///
    /// - Parameter midiInputName: Name of the instrument's MIDI input
    ///
    public init(midiInputName: String? = nil) {
        avAudioNode = AVAudioNode()
        name = midiInputName ?? MemoryAddress(of: self).description
        enableMIDI(name: name)
        hideVirtualMIDIPort()
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = MIDI.sharedInstance.client,
                         name: String? = nil) {
        let cfName = (name ?? self.name) as CFString
        CheckError(MIDIDestinationCreateWithBlock(midiClient, cfName, &midiIn) { packetList, _ in
            // While packetList is still valid, read events out.
            let events = packetList.pointee.map( { MIDIEvent(packet: $0 )})
            DispatchQueue.main.async {
                for event in events {
                    self.handle(event: event)
                }
            }
        })
    }

    private func handle(event: MIDIEvent) {
        guard event.data.count > 2 else {
            return
        }
        self.handleMIDI(data1: event.data[0],
                        data2: event.data[1],
                        data3: event.data[2])
    }
    
    // MARK: - Handling MIDI Data
    
    /// Handle MIDI commands that come in externally
    /// - Parameters:
    ///   - noteNumber: MIDI Note Numbe
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///   - portID: Incoming MIDI Source
    ///   - offset: Sample accurate timing offset
    open func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                 velocity: MIDIVelocity,
                                 channel: MIDIChannel,
                                 portID: MIDIUniqueID? = nil,
                                 timeStamp: MIDITimeStamp? = nil) {
        mpeActiveNotes.append((noteNumber, channel))
        if velocity > 0 {
            start(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }
    
    /// Handle MIDI commands that come in externally
    /// - Parameters:
    ///   - noteNumber: MIDI Note Numbe
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///   - portID: Incoming MIDI Source
    ///   - offset: Sample accurate timing offset
    open func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel,
                                  portID: MIDIUniqueID? = nil,
                                  timeStamp: MIDITimeStamp? = nil) {
        stop(noteNumber: noteNumber, channel: channel)
        mpeActiveNotes.removeAll(where: { $0 == (noteNumber, channel) })
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
    open func receivedMIDIController(_ controller: MIDIByte,
                                     value: MIDIByte, channel: MIDIChannel,
                                     portID: MIDIUniqueID? = nil,
                                     timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
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
    open func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
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
    open func receivedMIDIAftertouch(_ pressure: MIDIByte,
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
    open func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
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
    open func receivedMIDIProgramChange(_ program: MIDIByte,
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
    open func receivedMIDISystemCommand(_ data: [MIDIByte],
                                        portID: MIDIUniqueID? = nil,
                                        timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// MIDI Setup has changed
    open func receivedMIDISetupChange() {
        // Do nothing
    }

    /// MIDI Object Property has changed
    open func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    /// Generic MIDI Notification
    open func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to play
    ///   - velocity:   Velocity at which to play the note (0 - 127)
    ///   - channel:    Channel on which to play the note
    ///
    open func start(noteNumber: MIDINoteNumber,
                    velocity: MIDIVelocity,
                    channel: MIDIChannel,
                    timeStamp: MIDITimeStamp? = nil) {
        // Override in subclass
    }

    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    open func stop(noteNumber: MIDINoteNumber,
                   channel: MIDIChannel,
                   timeStamp: MIDITimeStamp? = nil) {
        // Override in subclass
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    open func receivedMIDIProgramChange(_ program: MIDIByte,
                                        channel: MIDIChannel,
                                        timeStamp: MIDITimeStamp? = nil) {
        // Override in subclass
    }

    // MARK: - Private functions

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        if let status = MIDIStatus(byte: data1), let statusType = status.type {

            let channel = status.channel

            switch statusType {
            case .noteOn:
                if data3 > 0 {
                    start(noteNumber: data2, velocity: data3, channel: channel)
                } else {
                    stop(noteNumber: data2, channel: channel)
                }
            case .noteOff:
                stop(noteNumber: data2, channel: channel)
            case .polyphonicAftertouch:
                receivedMIDIAftertouch(noteNumber: data2,
                                       pressure: data3,
                                       channel: channel)
            case .channelAftertouch:
                receivedMIDIAftertouch(data2,
                                       channel: channel)
            case .controllerChange:
                receivedMIDIController(data2,
                                       value: data3,
                                       channel: channel)
            case .programChange:
                receivedMIDIProgramChange(data2, channel: channel)
            case .pitchWheel:
                receivedMIDIPitchWheel(MIDIWord(byte1: data2,
                                                byte2: data3),
                                       channel: channel)
            }
        }
    }

    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 0)
    }

    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 1)
    }
}

#endif
