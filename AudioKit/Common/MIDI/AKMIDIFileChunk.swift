//
//  AKAKMIDIFileChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

protocol AKMIDIFileChunk {
    var typeData: [UInt8] { get set }
    var lengthData: [UInt8] { get set }
    var data: [UInt8] { get set }
    init()
    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8])
}

extension AKMIDIFileChunk {

    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8]) {
        self.init()
        self.typeData = typeData
        self.lengthData = lengthData
        self.data = data
        if !isValid {
            fatalError("Type and length must be 4 bytes long")
        }
    }

    var isValid: Bool {
        return typeData.count == 4 && lengthData.count == 4 && data.count == combine(bytes: lengthData) && (isHeader || isTrack)
    }

    var length: Int {
        return combine(bytes: lengthData)
    }

    var type: String {
        return String(self.typeData.map({ Character(UnicodeScalar($0)) }))
    }

    var isHeader: Bool {
        return type == "MThd"
    }

    var isTrack: Bool {
        return type == "MTrk"
    }

    func combine(bytes: [UInt8]) -> Int {
        return Int(bytes.map(String.init).joined()) ?? 0
    }
}

struct MIDIFileTrackChunk: AKMIDIFileChunk {

    var typeData: [UInt8] = Array(repeating: 0, count: 4)
    var lengthData: [UInt8] = Array(repeating: 0, count: 4)
    var data: [UInt8] = []

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

    var events: [AKMIDIEvent] {
        var events = [AKMIDIEvent]()

        return events
    }

    private func parseData() {
        var events = [AKMIDIEvent]()
        var currentTimeByte: MIDIByte?
        var currentTypeByte: MIDIByte?
        var currentLengthByte: MIDIByte?
        var currentEventData = [MIDIByte]()
        for byte in data {
            if UInt8(currentEventData.count) == currentLengthByte {
                let typeAndLength = [currentTypeByte!, currentLengthByte!]
                let event = AKMIDIEvent(data: typeAndLength + currentEventData)
                currentTimeByte = nil
                currentTypeByte = nil
                currentLengthByte = nil
                currentEventData.removeAll()
            }
            if currentTimeByte == nil {
                currentTimeByte = byte
            } else if currentTypeByte == nil {
                currentTypeByte = byte
            } else if currentLengthByte == nil {
                currentLengthByte = byte
            } else {
                currentEventData.append(byte)
            }
        }
    }
}

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
        return Int(convertTo16Bit(msb: data[0], lsb: data[1]))
    }

    var numTracks: Int {
        return Int(convertTo16Bit(msb: data[2], lsb: data[3]))
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
        if timeFormat == .ticksPerBeat {
            return Int((timeDivision & 0x7f00) >> 8)
        }
        return nil
    }

    var ticksPerFrame: Int? {
        if timeFormat == .ticksPerBeat {
            return Int(timeDivision & 0xff)
        }
        return nil
    }

    var timeDivision: UInt16 {
        return convertTo16Bit(msb: data[4], lsb: data[5])
    }

    func convertTo16Bit(msb: UInt8, lsb: UInt8) -> UInt16 {
        return (UInt16(msb) << 8) | UInt16(lsb)
    }

}
