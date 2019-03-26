//
//  AKMIDIFileHeaderChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public struct MIDIFileHeaderChunk: AKMIDIFileChunk {

    public var typeData: [UInt8]
    public var lengthData: [UInt8]
    public var data: [UInt8]

    public init() {
        typeData = Array(repeating: 0, count: 4)
        lengthData = Array(repeating: 0, count: 4)
        data = []
    }

    public init(chunk: AKMIDIFileChunk) {
        self.typeData = chunk.typeData
        self.lengthData = chunk.lengthData
        self.data = chunk.data
    }

    public var format: Int {
        return Int(convertTo16Bit(msb: data[0], lsb: data[1]))
    }

    public var numTracks: Int {
        return Int(convertTo16Bit(msb: data[2], lsb: data[3]))
    }

    public var timeFormat: MIDITimeFormat {
        if((timeDivision & 0x8000) == 0) {
            return .ticksPerBeat
        } else {
            return .framesPerSecond
        }
    }

    public var ticksPerBeat: Int? {
        if timeFormat == .ticksPerBeat {
            return Int(timeDivision & 0x7fff)
        }
        return nil
    }

    public var framesPerSecond: Int? {
        if timeFormat == .ticksPerBeat {
            return Int((timeDivision & 0x7f00) >> 8)
        }
        return nil
    }

    public var ticksPerFrame: Int? {
        if timeFormat == .ticksPerBeat {
            return Int(timeDivision & 0xff)
        }
        return nil
    }

    public var timeDivision: UInt16 {
        return convertTo16Bit(msb: data[4], lsb: data[5])
    }

    func convertTo16Bit(msb: UInt8, lsb: UInt8) -> UInt16 {
        return (UInt16(msb) << 8) | UInt16(lsb)
    }

}
