// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public class MIDIHelper {

    static public func convertTo16Bit(msb: UInt8, lsb: UInt8) -> UInt16 {
        return (UInt16(msb) << 8) | UInt16(lsb)
    }

    static public func convertTo32Bit(msb: UInt8, data1: UInt8, data2: UInt8, lsb: UInt8) -> UInt32 {
        var value: UInt32 = UInt32(lsb) & 0xFF
        value |= (UInt32(data2) << 8) & 0xFFFF
        value |= (UInt32(data1) << 16) & 0xFFFFFF
        value |= (UInt32(msb) << 24) & 0xFFFFFFFF
        return value
    }

    static public func convertToString(bytes: [UInt8]) -> String {
        return bytes.map(String.init).joined()
    }

    static public func convertToASCII(bytes: [UInt8]) -> String? {
        return String(bytes: bytes, encoding: .utf8)
    }
}
