// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit

func encodeSysex<T>(_ value: T) -> [UInt8] {

    // Start with a sysex header.
    var result: [UInt8] = [0xF0, 0x00]

    withUnsafeBytes(of: value) { ptr in
        for byte in ptr {
            result.append( byte >> 4 )
            result.append( byte & 0xF )
        }
    }

    result.append(0xF7)
    return result
}

func decodeSysex<T>(_ bytes: UnsafePointer<UInt8>, count: Int, _ value: inout T) {

    // Number of bytes should include sysex header (0xF0, 0x00) and terminator (0xF7).
    assert(count == 2*MemoryLayout<T>.size + 3)

    withUnsafeMutableBytes(of: &value) { ptr in
        for i in 0..<ptr.count {
            ptr[i] = (bytes[2*i+2] << 4) | (bytes[2*i+3])
        }
    }
}

func withMidiData(_ event: UnsafePointer<AURenderEvent>, _ f: (UnsafePointer<UInt8>) -> ()) {

    let length = event.pointee.MIDI.length
    if let offset = MemoryLayout.offset(of: \AUMIDIEvent.data) {

        let raw = UnsafeRawPointer(event)! + offset

        raw.withMemoryRebound(to: UInt8.self, capacity: Int(length)) { pointer in
            f(pointer)
        }
    }
}
