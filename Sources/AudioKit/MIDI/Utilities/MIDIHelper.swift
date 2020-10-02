// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public class MIDIHelper {

    static public func convertTo16Bit(msb: MIDIByte, lsb: MIDIByte) -> UInt16 {
        return (UInt16(msb) << 8) | UInt16(lsb)
    }

    static public func convertTo32Bit(msb: MIDIByte, data1: MIDIByte, data2: MIDIByte, lsb: MIDIByte) -> UInt32 {
        var value: UInt32 = UInt32(lsb) & 0xFF
        value |= (UInt32(data2) << 8) & 0xFFFF
        value |= (UInt32(data1) << 16) & 0xFFFFFF
        value |= (UInt32(msb) << 24) & 0xFFFFFFFF
        return value
    }

    static public func convertToString(bytes: [MIDIByte]) -> String {
        return bytes.map(String.init).joined()
    }

    static public func convertToASCII(bytes: [MIDIByte]) -> String? {
        return String(bytes: bytes, encoding: .utf8)
    }
}
