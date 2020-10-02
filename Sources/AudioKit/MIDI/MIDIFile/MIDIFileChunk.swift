// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// MIDI File Chunk Protocol
public protocol MIDIFileChunk {
    /// All data used to init this chunk
    var rawData: [MIDIByte] { get }
    /// The subset of data used to determine type ("MTrk" or "MThd")
    var typeData: [MIDIByte] { get }
    /// The subset of data used to determine chunk length
    var lengthData: [MIDIByte] { get }
    /// The subset of data that contains events, etc
    var data: [MIDIByte] { get }

    /// Initialize with data
    /// - Parameter data: MIDI Byte array
    init?(data: [MIDIByte])
}

/// Default behavior for MIDI FIle Chunks
public extension MIDIFileChunk {

    /// Is valid chunk
    var isValid: Bool { return isTypeValid && isLengthValid }
    /// Is not a valid chunk
    var isNotValid: Bool { return !isValid }
    /// Is chunk type valid?
    var isTypeValid: Bool { return typeData.count == 4 && lengthData.count == 4 }
    /// Is length valid?
    var isLengthValid: Bool { return data.count == length }

    /// Length of file chunk
    var length: Int {
        return Int(MIDIHelper.convertTo32Bit(msb: lengthData[0],
                                             data1: lengthData[1],
                                             data2: lengthData[2],
                                             lsb: lengthData[3]))
    }

    /// Type data
    var typeData: [MIDIByte] {
        return Array(rawData[0..<4])
    }

    /// Length data
    var lengthData: [MIDIByte] {
        return Array(rawData[4..<8])
    }

    /// Raw data
    var data: [MIDIByte] {
        return Array(rawData.suffix(from: 8))
    }

    /// Chunk type
    var type: MIDIFileChunkType? {
        return MIDIFileChunkType(data: typeData)
    }

    /// Is Header
    var isHeader: Bool {
        return type == .header
    }

    /// Is Track
    var isTrack: Bool {
        return type == .track
    }
}

/// MIDI FIle Chunk type
public enum MIDIFileChunkType: String {
    /// Track chunk type
    case track = "MTrk"
    /// Header chunk type
    case header = "MThd"

    /// Initialize with data
    /// - Parameter data: MIDI Byte Array
    init?(data: [MIDIByte]) {
        let text = String(data.map({ Character(UnicodeScalar($0)) }))
        self.init(text: text)
    }

    /// Initialize with a string
    /// - Parameter text: Starting text
    init?(text: String) {
        self.init(rawValue: text)
    }

    /// Type as string
    var text: String {
        return self.rawValue
    }

    /// Data
    var midiBytes: [MIDIByte] {
        return [MIDIByte](text.utf8)
    }
}
