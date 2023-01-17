// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation
import CoreAudio
import os.log
import Utilities
import MIDI
import CoreMIDI
import MIDIKitIO
@_implementationOnly import MIDIKitInternals

/// MIDI receiving Sampler
///
/// Be sure to call enableMIDI() if you want to receive messages
///
open class MIDISampler: AppleSampler, NamedNode {
    // MARK: - Properties

    /// MIDI Input
    open var midiInputRef = MIDIEndpointRef()
    
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

    deinit {
        destroyEndpoint()
    }
    
    // MARK: - MIDI I/O
    
    private var midi1Parser: MIDI1Parser = .init()
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start AudioKit
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the MIDI client
    ///   - name: Name to connect with
    ///
    final public func enableMIDI(_ midiClient: MIDIClientRef = MIDI.shared.manager.coreMIDIClientRef,
                                 name: String? = nil) {
        // don't allow setup to run more than once
        guard midiInputRef == 0 else { return }
        
        let virtualInputName = (name ?? self.name) as CFString
        
        guard let midiBlock = au.scheduleMIDIEventBlock else {
            fatalError("Expected AU to respond to MIDI.")
        }
        
        let result = MIDIDestinationCreateWithBlock(midiClient, virtualInputName, &midiInputRef) { packetList, _ in
            packetList.pointee.packetPointerIterator { [weak self] packetPtr in
                let events = self?.midi1Parser.parsedEvents(in: packetPtr.rawBytes) ?? []
                for event in events {
                    let eventRawBytes = event.midi1RawBytes()
                    eventRawBytes.withUnsafeBufferPointer { bytesPtr in
                        guard let bytesBasePtr = bytesPtr.baseAddress else { return }
                        midiBlock(AUEventSampleTimeImmediate, 0, eventRawBytes.count, bytesBasePtr)
                    }
                }
            }
        }
        
        CheckError(result)
    }

    // MARK: - Handling MIDI Data
    
    /// Handle MIDI events that arrive externally
    public func handle(event: MIDIEvent) throws {
        switch event {
        case .noteOn(let payload):
            switch payload.velocity.midi1Value {
            case 0:
                stop(noteNumber: payload.note.number.uInt8Value,
                     channel: payload.channel.uInt8Value)
            default:
                play(noteNumber: payload.note.number.uInt8Value,
                     velocity: payload.velocity.midi1Value.uInt8Value,
                     channel: payload.channel.uInt8Value)
            }
            
        case .noteOff(let payload):
            stop(noteNumber: payload.note.number.uInt8Value,
                 channel: payload.channel.uInt8Value)
            
        case .cc(let payload):
            samplerUnit.sendController(payload.controller.number.uInt8Value,
                                       withValue: payload.value.midi1Value.uInt8Value,
                                       onChannel: payload.channel.uInt8Value)
            
        default:
            break
        }
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
        self.samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
    }

    /// Stop a note
    open override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        self.samplerUnit.stopNote(noteNumber, onChannel: channel)
    }

    /// Discard all virtual ports
    public func destroyEndpoint() {
        if midiInputRef != 0 {
            MIDIEndpointDispose(midiInputRef)
            midiInputRef = 0
        }
    }

    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiInputRef, kMIDIPropertyPrivate, 0)
    }
    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiInputRef, kMIDIPropertyPrivate, 1)
    }
}

#endif
