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
        var currentTimeByte: Int?
        var currentTypeByte: MIDIByte?
        var currentLengthByte: MIDIByte?
        var currentEventData = [MIDIByte]()
        var isParsingMetaEvent = false
        var isParsingVariableTime = false
        var isParsingSysex = false
        var runningStatus: MIDIByte?
        var variableBits = [MIDIByte]()
        for byte in data {
            if currentTimeByte == nil {
                if byte & UInt8(0x80) == 0x80 { //Test if bit #7 of the byte is set
                    isParsingVariableTime = true
                    variableBits.append(byte)
                } else {
                    if isParsingVariableTime {
                        variableBits.append(byte)
                        var time: UInt16 = 0
                        for variable in variableBits {
                            let shifted: UInt16 = UInt16(time << 7)
                            let masked: MIDIByte = variable & 0x7f
                            time = shifted + UInt16(masked)
                        }
                        currentTimeByte = Int(time)
                        isParsingVariableTime = false
                    } else {
                        currentTimeByte = Int(byte)
                    }
                }
            } else if currentTypeByte == nil {
                if byte == 0xFF { //MetaEvent
                    isParsingMetaEvent = true
                } else {
                    if let _ = AKMIDIStatusType.from(byte: byte) {
                        currentTypeByte = byte
                        runningStatus = byte
                    } else if AKMIDISystemCommand(rawValue: byte) != nil {
                        currentTypeByte = byte
                    } else if AKMIDIMetaEventType(rawValue: byte) != nil {
                        currentTypeByte = byte
                    } else if let statusByte = runningStatus, let status = AKMIDIStatusType.from(byte: statusByte) {
                        let length = MIDIByte(status.length ?? AKMIDISystemCommand(rawValue: statusByte)?.length ?? 0)
                        currentTypeByte = statusByte
                        currentEventData.append(statusByte)
                        currentLengthByte = length
                    }
                }
                if let command = AKMIDISystemCommand(rawValue: byte), command == .sysex || command == .sysexEnd {
                    isParsingSysex = true
                    runningStatus = nil
                    currentTypeByte = byte
                }
                if !isParsingMetaEvent && !isParsingSysex {
                    currentEventData.append(byte)
                }
            } else if currentLengthByte == nil {
                if isParsingMetaEvent {
                    currentLengthByte = byte
                } else {
                    if let type = currentTypeByte {
                        if let command = AKMIDISystemCommand(rawValue: type) {
                            if command == .sysexEnd || command == .sysex {
                                currentLengthByte = byte
                            } else {
                                currentLengthByte = MIDIByte(command.length)
                            }
                        } else if let status = AKMIDIStatusType.from(byte: type) {
                            if let length = status.length {
                                currentLengthByte = MIDIByte(length)
                            } else {
                                AKLog(("bad midi data - is system command, but not parsed as system command"))
                                return events
                            }
                        } else {
                            AKLog(("bad midi data - could not determine length of event"))
                            return events
                        }
                    } else {
                        AKLog(("bad midi data - could not determine type"))
                        return events
                    }
                    if !isParsingSysex {
                        currentEventData.append(byte)
                    }
                }
            } else {
                currentEventData.append(byte)
            }
            if let time = currentTimeByte, let type = currentTypeByte, let length = currentLengthByte,
                UInt8(currentEventData.count) == currentLengthByte {
                let chunkEvent = AKMIDIFileChunkEvent(time: time, type: type, length: length, data: currentEventData)
                let event = AKMIDIEvent(fileEvent: chunkEvent)
                events.append(event)
                currentTimeByte = nil
                currentTypeByte = nil
                currentLengthByte = nil
                isParsingMetaEvent = false
                isParsingSysex = false
                currentEventData.removeAll()
                variableBits.removeAll()
            }
        }
        return events
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

public struct AKMIDIFileChunkEvent {
    var time: Int
    var type: MIDIByte
    var length: MIDIByte
    var data: [MIDIByte]
}
