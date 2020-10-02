// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension MIDIByte {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> MIDIByte {
        return self & 0x7F
    }

    /// [Recommendation] - half of a byte is called a nibble.
    /// It's not called the lowBit and highBit.
    /// It's confusing to refer to these as highBit and lowBit because
    /// it sounds like your are referring to the highest bit and the lowest bit

    /// This limits the range to be from 0 to 16
    public var lowBit: MIDIByte {
        return self & 0xF
    }

    /// High Bit
    public var highBit: MIDIByte {
        return self >> 4
    }

    /// Value as traditional hex string
    public var hex: String {
        let st = String(format: "%02X", self)
        return "0x\(st)"
    }
}

extension Array where Element == MIDIByte {
    var hex: String {
        return self.map({ $0.hex.replacingOccurrences(of: "0x", with: "") }).joined(separator: "")
    }

    var integerValue: Int? {
        return Int(hex, radix: 16)
    }
}

extension MIDIWord {
    /// Construct a 14 bit integer MIDIWord value
    ///
    /// This would be used for converting two incoming MIDIBytes into a useable value
    ///
    /// - Parameters:
    ///   - byte1: The least significant byte in the 14 bit integer value
    ///   - byte2: The most significant byte in the 14 bit integer value
    init(byte1: MIDIByte, byte2: MIDIByte) {
        let x = MIDIWord(byte1)
        let y = MIDIWord(byte2) << 7
        self = y + x
    }

    /// Create a MIDIWord for a command and command version
    /// [command byte][version byte]
    ///
    /// This is used to construct a word that would be sent in SysEx
    ///
    /// - Parameters:
    ///   - command: Command Byte Value
    ///   - version: Command Byte Version Value
    init(command: MIDIByte, version: MIDIByte) {
        self = MIDIWord((command << 8) | version)
    }

    /// Create a MIDIWord from a byte by taking the upper nibble
    /// and lower nibble of a byte, and separating each into a
    /// byte in the MIDIWord
    ///
    /// - Parameter ioBitmap: Full 8bits of ioMapping for one output
    init(ioBitmap: MIDIByte) {
        let high = (ioBitmap & 0xF0) >> 4
        let low = ioBitmap & 0x0F
        self = UInt16(high << 8) | UInt16(low)
    }

    /// Most significant byte in a MIDIWord
    var msb: MIDIByte {
        return MIDIByte(self >> 8)
    }

    /// Lease significant byte in a MIDIWord
    var lsb: MIDIByte {
        return MIDIByte(self & 0x00FF)
    }
}

/// MIDI Time Format
public enum MIDITimeFormat: Int {
    /// Ticks Per Beat
    case ticksPerBeat = 0
    /// Frames per second
    case framesPerSecond = 1

    var description: String {
        switch self {
        case .ticksPerBeat:
            return "TicksPerBeat"
        case .framesPerSecond:
            return "FramesPerSecond"
        }
    }
}
