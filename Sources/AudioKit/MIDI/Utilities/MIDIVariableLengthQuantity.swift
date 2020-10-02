// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// MIDI Varialbe Length Quantity
public struct MIDIVariableLengthQuantity {
    /// Data in bytes
    public let data: [MIDIByte]
    /// Length of the quantity
    public var length: Int { return vlqResult.0 }
    /// Quantity
    public var quantity: UInt32 { return vlqResult.1 }
    private let vlqResult: (Int, UInt32)

    /// Initialize from bytes
    /// - Parameter data: Array slide of MIDI Bytes
    public init?(fromBytes data: ArraySlice<MIDIByte>) {
        self.init(fromBytes: Array(data))
    }

    /// Initialize from arry
    /// - Parameter data: MIDI Byte array
    public init?(fromBytes data: [MIDIByte]) {
        guard data.isNotEmpty else { return nil }
        vlqResult = MIDIVariableLengthQuantity.read(bytes: data)
        self.data = Array(data.prefix(vlqResult.0))
        guard self.data.count == length else { return nil }
    }

    /// Read from array of MIDI Bytes
    /// - Parameter bytes: Array of MIDI Bytes
    /// - Returns: Tuple of processed byte count and result UInt32
    public static func read(bytes: [MIDIByte]) -> (Int, UInt32) {
        var processedBytes = 0
        var result: UInt32 = 0
        var lastByte: MIDIByte = 0xFF
        var byte = bytes[processedBytes]

        while lastByte & 0x80 == 0x80 && processedBytes < bytes.count {
            let shifted = result << 7
            let masked: MIDIByte = byte & 0x7f
            result = shifted | UInt32(masked)
            processedBytes += 1
            lastByte = byte
            if processedBytes >= bytes.count {
                break
            }
            byte = bytes[processedBytes]
        }
        return (processedBytes, result)
    }
}
