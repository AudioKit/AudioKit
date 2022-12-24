// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit

/// Encode a value in a MIDI sysex message. Value must be plain-old-data.
func encodeSysex<T>(_ value: T) -> [UInt8] {

    // Start with a sysex header.
    var result: [UInt8] = [0xF0, 0x00]

    // Encode the value as a sequence of nibbles.
    // There might be some more efficient way to do this,
    // but we can't clash with the 0xF7 end-of-message.
    // We may not actually need to encode a valid MIDI sysex
    // message, but that could be implementation dependent
    // and change over time. Best to be safe.
    withUnsafeBytes(of: value) { ptr in
        for byte in ptr {
            result.append( byte >> 4 )
            result.append( byte & 0xF )
        }
    }

    result.append(0xF7)
    return result
}

/// Decode a sysex message into a value. Value must be plain-old-data.
///
/// We can't return a value because we can't assume the value can be
/// default constructed.
///
/// - Parameters:
///   - bytes: the sysex message
///   - count: number of bytes in message
///   - value: the value we're writing to
///
func decodeSysex<T>(_ bytes: UnsafePointer<UInt8>, count: Int, _ value: inout T) {

    // Number of bytes should include sysex header (0xF0, 0x00) and terminator (0xF7).
    assert(count == 2*MemoryLayout<T>.size + 3)

    withUnsafeMutableBytes(of: &value) { ptr in
        for i in 0..<ptr.count {
            ptr[i] = (bytes[2*i+2] << 4) | (bytes[2*i+3])
        }
    }
}

/// Call a function with a pointer to the midi data in the AURenderEvent.
///
/// We need this function because event.pointee.MIDI.data is just a tuple of three midi bytes. This is
/// fine for simple midi messages like note on/off, but some messages are longer, so we need
/// access to the full array, which extends off the end of the structure (one of those variable-length C structs).
///
/// - Parameters:
///   - event: pointer to the AURenderEvent
///   - f: function to call
func withMidiData(_ event: UnsafePointer<AURenderEvent>, _ f: (UnsafePointer<UInt8>) -> ()) {

    let type = event.pointee.head.eventType
    assert(type == .midiSysEx || type == .MIDI)

    let length = event.pointee.MIDI.length
    if let offset = MemoryLayout.offset(of: \AUMIDIEvent.data) {

        let raw = UnsafeRawPointer(event)! + offset

        raw.withMemoryRebound(to: UInt8.self, capacity: Int(length)) { pointer in
            f(pointer)
        }
    }
}

/// Decode a value from a sysex AURenderEvent.
///
/// We can't return a value because we can't assume the value can be
/// default constructed.
///
/// - Parameters:
///   - event: pointer to the AURenderEvent
///   - value: where we will store the value
func decodeSysex<T>(_ event: UnsafePointer<AURenderEvent>, _ value: inout T) {

    let type = event.pointee.head.eventType
    assert(type == .midiSysEx)

    let length = event.pointee.MIDI.length
    withMidiData(event) { ptr in
        decodeSysex(ptr, count: Int(length), &value)
    }
}
