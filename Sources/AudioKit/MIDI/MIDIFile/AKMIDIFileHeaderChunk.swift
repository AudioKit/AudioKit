// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

struct MIDIFileHeaderChunk: AKMIDIFileChunk {

    var rawData: [UInt8]

    public init?(data: [UInt8]) {
        guard
            data.count > 8
        else {
            return nil
        }
        let lengthBytes = Array(data[4..<8])
        let length = Int(MIDIHelper.convertTo32Bit(msb: lengthBytes[0],
                                                   data1: lengthBytes[1],
                                                   data2: lengthBytes[2],
                                                   lsb: lengthBytes[3]))
        rawData = Array(data.prefix(upTo: length + 8)) //the message + 4 byte header type, + 4 byte length
        if isNotValid || !isHeader {
            return nil
        }
    }

    init?(chunk: AKMIDIFileChunk) {
        guard chunk.type == .header else {
            return nil
        }
        rawData = chunk.rawData
    }

    var format: Int {
        return Int(MIDIHelper.convertTo16Bit(msb: data[0], lsb: data[1]))
    }

    var numTracks: Int {
        return Int(MIDIHelper.convertTo16Bit(msb: data[2], lsb: data[3]))
    }

    var timeFormat: MIDITimeFormat {
        if (timeDivision & 0x8000) == 0 {
            return .ticksPerBeat
        } else {
            return .framesPerSecond
        }
    }

    var ticksPerBeat: Int? {
        if timeFormat == .ticksPerBeat {
            return Int(timeDivision & 0x7fff)
        }
        return nil
    }

    var framesPerSecond: Int? {
        if timeFormat == .framesPerSecond {
            return Int((timeDivision & 0x7f00) >> 8)
        }
        return nil
    }

    var ticksPerFrame: Int? {
        if timeFormat == .framesPerSecond {
            return Int(timeDivision & 0xff)
        }
        return nil
    }

    var timeDivision: UInt16 {
        return MIDIHelper.convertTo16Bit(msb: data[4], lsb: data[5])
    }

}
