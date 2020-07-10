//
//  AKMIDIFileHeaderChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

struct MIDIFileHeaderChunk: AKMIDIFileChunk {

    var rawData: [UInt8]

    public init?(data: [UInt8]) {
        self.init()
        rawData = data
        rawData = Array(data.prefix(upTo: length + lengthData.count + typeData.count))
        if isNotValid || !isHeader {
            return nil
        }
    }

    init() {
        rawData = MIDIFileChunkType.header.midiBytes
        rawData.append(contentsOf: Array(repeating: UInt8(0), count: 4))
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
        if((timeDivision & 0x8000) == 0) {
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
