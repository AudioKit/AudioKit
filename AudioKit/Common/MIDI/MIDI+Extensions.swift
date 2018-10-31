//
//  MIDIByte+Extensions.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/31/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public typealias MIDIByte = UInt8
public typealias MIDIWord = UInt16
public typealias MIDINoteNumber = UInt8
public typealias MIDIVelocity = UInt8
public typealias MIDIChannel = UInt8

extension MIDIByte {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> MIDIByte {
        return self & 0x7F
    }

    /// This limits the range to be from 0 to 16
    func lowbit() -> MIDIByte {
        return self & 0xF
    }

    var status: AKMIDIStatus? {
        return AKMIDIStatus.statusFrom(byte: self)
    }

    var channel: MIDIChannel? {
        return self & 0x0F
    }
}

extension MIDIPacket {
    var isSysex: Bool {
        return data.0 == AKMIDISystemCommand.sysex.rawValue
    }

    var status: AKMIDIStatus? {
        return data.0.status
    }

    var channel: MIDIChannel {
        return data.0.lowbit()
    }

    var command: AKMIDISystemCommand? {
        return AKMIDISystemCommand(rawValue: data.0)
    }
}

enum MIDITimeFormat: Int {
    case ticksPerBeat = 0
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

protocol MIDIFileChunk {
    var typeData: [UInt8] { get set }
    var lengthData: [UInt8] { get set }
    var data: [UInt8] { get set }
    init()
    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8]) 
}

extension MIDIFileChunk {

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
        return String(self.typeData.map({ Character(UnicodeScalar($0)) })) == "MThd"
    }

    var isTrack: Bool {
        return String(self.typeData.map({ Character(UnicodeScalar($0)) })) == "MTrk"
    }

    func combine(bytes: [UInt8]) -> Int {
        return Int(bytes.map(String.init).joined()) ?? 0
    }
}

struct MIDIFileTrackChunk: MIDIFileChunk {

    var typeData: [UInt8] = Array(repeating: 0, count: 4)
    var lengthData: [UInt8] = Array(repeating: 0, count: 4)
    var data: [UInt8] = []

    init() {
        typeData = Array(repeating: 0, count: 4)
        lengthData = Array(repeating: 0, count: 4)
        data = []
    }

    init(chunk: MIDIFileChunk) {
        self.typeData = chunk.typeData
        self.lengthData = chunk.lengthData
        self.data = chunk.data
    }
}

struct MIDIFileHeaderChunk: MIDIFileChunk {

    var typeData: [UInt8]
    var lengthData: [UInt8]
    var data: [UInt8]

    init() {
        typeData = Array(repeating: 0, count: 4)
        lengthData = Array(repeating: 0, count: 4)
        data = []
    }

    init(chunk: MIDIFileChunk) {
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
