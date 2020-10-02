// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// MIDI System Exclusive Message
public struct MIDISysExMessage: MIDIMessage {
    /// Data in bytes
    public let data: [MIDIByte]
    /// Length of sysex message
    public let length: Int
    /// Pretty printout
    public var description: String {
        return "MIDI SysEx message \(length) bytes long"
    }

    /// Initialize with bytes
    /// - Parameter bytes: MIDI Bytes
    public init?(bytes: [MIDIByte]) {
        guard
            bytes.count > 2,
            bytes[0] == 0xF0,
            let vlqLength = MIDIVariableLengthQuantity(fromBytes: bytes.suffix(from: 1))
        else {
            return nil
        }
        self.data = Array(bytes.prefix(2 + Int(vlqLength.quantity))) //2 is for F0 and F7
        self.length = Int(vlqLength.quantity)
    }

}
