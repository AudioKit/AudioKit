// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public protocol AKMIDIFileChunk {
    var rawData: [UInt8] { get }    // All data used to init this chunk
    var typeData: [UInt8] { get }       // The subset of data used to determine type ("MTrk" or "MThd")
    var lengthData: [UInt8] { get }     // The subset of data used to determine chunk length
    var data: [UInt8] { get }           // The subset of data that contains events, etc
    init?(data: [UInt8])
}

public extension AKMIDIFileChunk {

    var isValid: Bool { return isTypeValid && isLengthValid }
    var isNotValid: Bool { return !isValid }
    var isTypeValid: Bool { return typeData.count == 4 && lengthData.count == 4 }
    var isLengthValid: Bool { return data.count == length }

    var length: Int {
        return Int(MIDIHelper.convertTo32Bit(msb: lengthData[0],
                                             data1: lengthData[1],
                                             data2: lengthData[2],
                                             lsb: lengthData[3]))
    }

    var typeData: [UInt8] {
        return Array(rawData[0..<4])
    }

    var lengthData: [UInt8] {
        return Array(rawData[4..<8])
    }

    var data: [UInt8] {
        return Array(rawData.suffix(from: 8))
    }

    var type: MIDIFileChunkType? {
        return MIDIFileChunkType(data: typeData)
    }

    var isHeader: Bool {
        return type == .header
    }

    var isTrack: Bool {
        return type == .track
    }
}

public enum MIDIFileChunkType: String {
    case track = "MTrk"
    case header = "MThd"

    init?(data: [UInt8]) {
        let text = String(data.map({ Character(UnicodeScalar($0)) }))
        self.init(text: text)
    }

    init?(text: String) {
        self.init(rawValue: text)
    }

    var text: String {
        return self.rawValue
    }

    var midiBytes: [UInt8] {
        return [UInt8](text.utf8)
    }
}
