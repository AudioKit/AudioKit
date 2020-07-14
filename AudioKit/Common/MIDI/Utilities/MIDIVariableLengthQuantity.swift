// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public struct MIDIVariableLengthQuantity {
    public let data: [UInt8]
    public var length: Int { return vlqResult.0 }
    public var quantity: UInt32 { return vlqResult.1 }
    private let vlqResult: (Int, UInt32)

    public init?(fromBytes data: ArraySlice<UInt8>) {
        self.init(fromBytes: Array(data))
    }

    public init?(fromBytes data: [UInt8]) {
        guard data.isNotEmpty else { return nil }
        vlqResult = MIDIVariableLengthQuantity.read(bytes: data)
        self.data = Array(data.prefix(vlqResult.0))
        guard self.data.count == length else { return nil }
    }

    public static func read(bytes: [UInt8]) -> (Int, UInt32) {
        var processedBytes = 0
        var result: UInt32 = 0
        var lastByte: UInt8 = 0xFF
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
