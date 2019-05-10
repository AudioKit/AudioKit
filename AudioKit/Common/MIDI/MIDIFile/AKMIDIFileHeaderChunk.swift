//
//  AKMIDIFileHeaderChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

struct MIDIFileHeaderChunk: AKMIDIFileChunk {

    var typeData: [UInt8]
    var lengthData: [UInt8]
    var data: [UInt8]

    init() {
        typeData = Array(repeating: 0, count: 4)
        lengthData = Array(repeating: 0, count: 4)
        data = []
    }

    init(chunk: AKMIDIFileChunk) {
        self.typeData = chunk.typeData
        self.lengthData = chunk.lengthData
        self.data = chunk.data
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
