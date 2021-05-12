// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation
import CoreAudio
import os.log

/// MIDI receiving Sampler
///
/// Be sure to enableMIDI if you want to receive messages
///
open class MIDISampler: AppleSampler, NamedNode {
    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "(unset)"

    /// Initialize the MIDI Sampler
    ///
    /// - Parameter midiOutputName: Name of the instrument's MIDI output
    ///
    public init(name midiOutputName: String? = nil) {
        super.init()
        name = midiOutputName ?? MemoryAddress(of: self).description
        enableMIDI(name: name)
        hideVirtualMIDIPort()
    }

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

    private func handle(event: MIDIEvent) throws {
        try self.handleMIDI(data1: event.data[0],
                            data2: event.data[1],
                            data3: event.data[2])
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) throws {
        if let status = MIDIStatus(byte: data1) {
            let channel = status.channel
            if status.type == .noteOn && data3 > 0 {
                play(noteNumber: data2,
                     velocity: data3,
                     channel: channel)
            } else if status.type == .noteOn && data3 == 0 {
                stop(noteNumber: data2, channel: channel)
            } else if status.type == .controllerChange {
                midiCC(data2, value: data3, channel: channel)
            }
        }
    }

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel) throws {
        if velocity > 0 {
            play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }

    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - controller: MIDI CC number
    ///   - value: MIDI CC value
    ///   - channel: MIDI CC channel
    ///
    public func midiCC(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        samplerUnit.sendController(controller, withValue: value, onChannel: channel)
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note or trigger a sample
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI note number
    ///   - velocity: MIDI velocity
    ///   - channel: MIDI channel
    ///
    /// NB: when using an audio file, noteNumber 60 will play back the file at normal
    /// speed, 72 will play back at double speed (1 octave higher), 48 will play back at
    /// half speed (1 octave lower) and so on
    open override func play(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        do {
            try ExceptionCatcher {
                self.samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
            }
        } catch {
            Log("Could not play MIDISampler note: \(error.localizedDescription)", type: .error)
        }
    }

    /// Stop a note
    open override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        do {
            try ExceptionCatcher {
                self.samplerUnit.stopNote(noteNumber, onChannel: channel)
            }
        } catch {
            Log("Could not stop MIDISampler note: \(error.localizedDescription)", type: .error)
        }
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
}

#endif
