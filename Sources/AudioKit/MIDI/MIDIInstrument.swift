// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CoreAudio

#if !os(tvOS)

/// A version of Instrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class MIDIInstrument: Node, MIDIListener, NamedNode, MIDIConnectable, MIDIPlayable {

    /// Connected nodes
    public var connections: [Node] { [] }

    /// The internal AVAudioEngine AVAudioNode
    public var avAudioNode: AVAudioNode

    // MARK: - Properties

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
    
    // MARK: - MIDIConnectable

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start AudioKit
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the MIDI client
    ///   - name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef = MIDI.sharedInstance.client,
                           name: String? = nil) {
        let cfName = (name ?? self.name) as CFString
        guard let midiBlock = avAudioNode.auAudioUnit.scheduleMIDIEventBlock else {
            fatalError("Expected AU to respond to MIDI.")
        }
        CheckError(MIDIDestinationCreateWithBlock(midiClient, cfName, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                e.forEach { event in
                    event.data.withUnsafeBufferPointer { ptr in
                        guard let ptr = ptr.baseAddress else { return }
                        midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
                    }
                }
            }
        })
    }
    
    /// Discard all virtual ports
    public func destroyEndpoint() {
        if midiIn != 0 {
            MIDIEndpointDispose(midiIn)
            midiIn = 0
        }
    }
    
    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 0)
    }
    
    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 1)
    }

    // MARK: - Handling MIDI Data (MIDIListener)
    
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
        // TODO: I doubt if this works as expected.
        // should move to start() and stop() instead
        mpeActiveNotes.append((noteNumber, channel))
        if velocity > 0 {
            start(noteNumber: noteNumber,
                  velocity: velocity,
                  channel: channel,
                  timeStamp: timeStamp)
        } else {
            stop(noteNumber: noteNumber,
                 channel: channel,
                 timeStamp: timeStamp)
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
        stop(noteNumber: noteNumber, channel: channel, timeStamp: timeStamp)
        // TODO: I doubt if this works as expected.
        // should move to start() and stop() instead
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

    // MARK: - MIDI Note Start/Stop (MIDIPlayable)

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
        // MIDIInstrument is useless without overriding in most cases
        fatalError("Override in subclass")
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
        // MIDIInstrument class is useless without overriding in most cases
        fatalError("Override in subclass")
    }
}

// MARK: - Deprecations

extension MIDIInstrument {
    // Send MIDI data to the audio unit
    @available(*, deprecated, message: "handleMIDI(data1:, data2:, data3) is depreated. Use handleMIDI(event:) instead.")
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let event = MIDIEvent(data: [data1, data2, data3])
        self.handleMIDI(event: event)
    }
}

#endif
