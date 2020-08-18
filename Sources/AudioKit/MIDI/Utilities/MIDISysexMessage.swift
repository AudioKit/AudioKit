// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public struct MIDISysExMessage: AKMIDIMessage {
    public let data: [UInt8]
    public let length: Int
    public var description: String {
        return "MIDI SysEx message \(length) bytes long"
    }

    public init?(bytes: [UInt8]) {
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
