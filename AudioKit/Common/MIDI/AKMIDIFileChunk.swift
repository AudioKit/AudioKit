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
        var currentAllData = [MIDIByte]()
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
                            currentLengthByte = MIDIByte(command.length ?? Int(byte))
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
            currentAllData.append(byte)
            if let time = currentTimeByte, let type = currentTypeByte, let length = currentLengthByte,
                UInt8(currentEventData.count) == currentLengthByte {
                var chunkEvent = AKMIDIFileChunkEvent(data: currentAllData)
                if chunkEvent.typeByte == nil, let running = runningStatus {
                    chunkEvent.runningStatus = AKMIDIStatus(byte: running)
                }
                if time != chunkEvent.deltaTime {
                    AKLog("MIDI File Parser time mismatch \(time) \(chunkEvent.deltaTime)")
                    break
                }
                if type != chunkEvent.typeByte {
                    AKLog("MIDI File Parser type mismatch \(type) \(chunkEvent.typeByte)")
                    break
                }
                if length != chunkEvent.length {
                    print(type)
                    AKLog("MIDI File Parser length mismatch \(length) \(chunkEvent.length)")
                    break
                }
                let event = AKMIDIEvent(fileEvent: chunkEvent)
                events.append(event)
                currentTimeByte = nil
                currentTypeByte = nil
                currentLengthByte = nil
                isParsingMetaEvent = false
                isParsingSysex = false
                currentEventData.removeAll()
                variableBits.removeAll()
                currentAllData.removeAll()
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
    var data: [MIDIByte]
    var runningStatus: AKMIDIStatus? = nil

    init(data: [MIDIByte]) {
        self.data = data
    }

    var eventData: [MIDIByte] {
        return Array(data.prefix(timeLength))
    }

    var deltaTime: Int {
        let timeBytes = data.prefix(timeLength)
        var time: UInt16  = 0
        for byte in timeBytes {
            let shifted: UInt16 = UInt16(time << 7)
            let masked: MIDIByte = byte & 0x7f
            time = shifted + UInt16(masked)
        }
        return Int(time)
    }

    private var timeLength: Int {
        return (data.firstIndex(where: { $0 < 0x80 }) ?? 0) + 1
    }

    var typeByte: MIDIByte? {
        if let index = typeIndex {
            return data[index]
        }
        return runningStatus?.byte
    }

    private var typeIndex: Int? {
        if data.count > timeLength {
            if data[timeLength] == 0xFF,
                data.count > timeLength + 1 { //is Meta-Event
                return timeLength + 1
            } else if let _ = AKMIDIStatus(byte: data[timeLength]) {
                return timeLength
            }
        }
        return nil
    }

    var length: Int {
        if let typeByte = self.typeByte {
            if let metaEvent = AKMIDIMetaEventType(rawValue: typeByte) {
                if let length = metaEvent.length {
                    return length
                } else if let index = typeIndex {
                    return Int(data[index + 1])
                }
            } else if let status = AKMIDIStatus(byte: typeByte) {
                if let command = status.command, let index = typeIndex {
                    return command.length ?? Int(data[index + 1])
                } else if let type = status.type {
                    return type.length ?? 0
                }
            }
        }
        return 0
    }
}
