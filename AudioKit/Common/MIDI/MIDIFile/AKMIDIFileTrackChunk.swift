//
//  AKMIDIFileTrackChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public struct MIDIFileTrackChunk: AKMIDIFileChunk {
    public var rawData: [UInt8]

    var timeFormat: MIDITimeFormat
    var timeDivision: Int

    public init?(data: [UInt8]) {
        self.init()
        rawData = data
        rawData = Array(data.prefix(upTo: length + lengthData.count + typeData.count))
        if isNotValid || !isTrack {
            return nil
        }
    }

    public init() {
        rawData = MIDIFileChunkType.header.midiBytes
        rawData.append(contentsOf: Array(repeating: UInt8(0), count: 4))
        timeFormat = .ticksPerBeat
        timeDivision = 480 //arbitrary value
    }

    init?(chunk: AKMIDIFileChunk, timeFormat: MIDITimeFormat, timeDivision: Int) {
        guard chunk.type == .track else {
            return nil
        }
        rawData = chunk.rawData
        self.timeFormat = timeFormat
        self.timeDivision = timeDivision
    }

    public var chunkEvents: [AKMIDIFileChunkEvent] {
        //FIXME: Not currently handling channel prefix
        var events = [AKMIDIFileChunkEvent]()
        var currentTime: UInt32?
        var currentTypeByte: MIDIByte?
        var currentLengthByte: MIDIByte?
        var currentEventData = [MIDIByte]()
        var currentAllData = [MIDIByte]()
        var isParsingMetaEvent = false
        var isNotParsingMetaEvent: Bool { return !isParsingMetaEvent }
        var isParsingSysex = false
        var isNotParsingSysex: Bool { return !isParsingSysex }
        var runningStatus: MIDIByte?
        var accumulatedDeltaTime = 0
        var currentTimeVLQ: MIDIVariableLengthQuantity?
        var processedBytes = 0
        while processedBytes < data.count {
            let subData = Array(data.suffix(from: processedBytes))
            let byte = data[processedBytes]
            var runningStatus: MIDIByte?
            if currentTimeVLQ == nil, let vlqTime = MIDIVariableLengthQuantity(fromBytes: subData) {
                print("got vlq time: \(vlqTime.quantity) - len: \(vlqTime.length)")
                currentTimeVLQ = vlqTime
                accumulatedDeltaTime += Int(vlqTime.quantity)
                processedBytes += vlqTime.length
            } else if let metaEvent = AKMIDIMetaEvent(data: subData) {
                print("got meta \(metaEvent.description)")
                let metaData = metaEvent.data
                let event = AKMIDIFileChunkEvent(data: metaData,
                                                 timeFormat: timeFormat, timeDivision: timeDivision,
                                                 timeOffset: accumulatedDeltaTime)
                events.append(event)
                processedBytes += metaEvent.data.count
                currentTimeVLQ = nil
                runningStatus = nil
            } else if let sysexEvent = MIDISysexMessage(bytes: subData) {
                print("got sysex \(sysexEvent.description)")
                let sysexData = sysexEvent.data
                let event = AKMIDIFileChunkEvent(data: sysexData,
                                                 timeFormat: timeFormat, timeDivision: timeDivision,
                                                 timeOffset: accumulatedDeltaTime)
                events.append(event)
                processedBytes += sysexEvent.data.count
                currentTimeVLQ = nil
                runningStatus = nil
            } else if let activeRunningStatus = runningStatus, let status = AKMIDIStatus(byte: activeRunningStatus) {
                print("got running status \(status.description)")
                let messageLength = status.length - 1 // drop one since running status is used
                let chunkData = Array(subData.prefix(messageLength))
                let event = AKMIDIFileChunkEvent(data: chunkData,
                                                 timeFormat: timeFormat, timeDivision: timeDivision,
                                                 timeOffset: accumulatedDeltaTime, runningStatus: status)
                events.append(event)
                processedBytes += messageLength
                currentTimeVLQ = nil
            } else if let status = AKMIDIStatus(byte: byte) {
                print("got new status \(status.description)")
                let messageLength = status.length
                let chunkData = Array(subData.prefix(messageLength))
                let event = AKMIDIFileChunkEvent(data: chunkData,
                                                 timeFormat: timeFormat, timeDivision: timeDivision,
                                                 timeOffset: accumulatedDeltaTime)
                events.append(event)
                processedBytes += messageLength
                currentTimeVLQ = nil
            }
            /*
            else if currentTypeByte == nil {
                if byte == 0xFF { //MetaEvent
                    isParsingMetaEvent = true
                } else {
                    if byte < 0x80, !isParsingMetaEvent, !isParsingSysex, let currentRunningStatus = runningStatus,
                        let status = AKMIDIStatus(byte: currentRunningStatus) { //Running Status Implied
                        currentTypeByte = currentRunningStatus
                        runningStatus = currentRunningStatus
                        let length = MIDIByte(status.length)
                        currentLengthByte = length
                        currentEventData.append(currentRunningStatus)
                    } else if AKMIDIStatusType.from(byte: byte) != nil {
                        currentTypeByte = byte
                        runningStatus = byte
                    } else if let command = AKMIDISystemCommand(rawValue: byte) {
                        currentTypeByte = byte
                        if command == .sysex || command == .sysexEnd {
                            isParsingSysex = true
                            runningStatus = nil
                        }
                    } else if AKMIDIMetaEventType(rawValue: byte) != nil {
                        currentTypeByte = byte
                        runningStatus = nil
                    }
                }
                if isNotParsingMetaEvent && isNotParsingSysex {
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
                            currentLengthByte = MIDIByte(status.length)
                        } else {
                            AKLog("bad midi data - could not determine length of event", log: OSLog.midi)
                            return events
                        }
                    } else {
                        AKLog("bad midi data - could not determine type", log: OSLog.midi)
                        return events
                    }
                    if isNotParsingSysex {
                        currentEventData.append(byte)
                    }
                }
            } else {
                currentEventData.append(byte)
            }
            currentAllData.append(byte)
            if let time = currentTime, let type = currentTypeByte, let length = currentLengthByte,
                UInt8(currentEventData.count) == currentLengthByte {
                var chunkEvent = AKMIDIFileChunkEvent(data: currentAllData, timeFormat: timeFormat,
                                                      timeDivision: timeDivision, timeOffset: accumulatedDeltaTime)
                if chunkEvent.typeByte == nil, let running = runningStatus {
                    chunkEvent.runningStatus = AKMIDIStatus(byte: running)
                }
                if time != chunkEvent.deltaTime {
                    AKLog("MIDI File Parser time mismatch \(time) vs. \(chunkEvent.deltaTime)", log: OSLog.midi)
                    break
                }
                if type != chunkEvent.typeByte {
                    AKLog("MIDI File Parser type mismatch \(type) vs. \(String(describing: chunkEvent.typeByte))", log: OSLog.midi)
                    break
                }
                if length != chunkEvent.length {
                    AKLog("MIDI File Parser length mismatch got \(length) expected \(chunkEvent.length) type: \(type)", log: OSLog.midi)
                    break
                }
                accumulatedDeltaTime += chunkEvent.deltaTime
                currentTime = nil
                currentTypeByte = nil
                currentLengthByte = nil
                currentTimeVLQ = nil
                isParsingMetaEvent = false
                isParsingSysex = false
                currentEventData.removeAll()
                currentAllData.removeAll()
                events.append(chunkEvent)
            }
            */
        
//
//        var currentByte = 0
//        for byte in data {
//            if currentTime == nil {
//                currentTime = MIDIVariableLengthQuantity(fromBytes: Array(data.suffix(from: currentByte)))?.quantity
//            } else if currentTypeByte == nil {
//                if byte == 0xFF { //MetaEvent
//                    isParsingMetaEvent = true
//                } else {
//                    if byte < 0x80, !isParsingMetaEvent, !isParsingSysex, let currentRunningStatus = runningStatus,
//                        let status = AKMIDIStatus(byte: currentRunningStatus) { //Running Status Implied
//                        currentTypeByte = currentRunningStatus
//                        runningStatus = currentRunningStatus
//                        let length = MIDIByte(status.length)
//                        currentLengthByte = length
//                        currentEventData.append(currentRunningStatus)
//                    } else if AKMIDIStatusType.from(byte: byte) != nil {
//                        currentTypeByte = byte
//                        runningStatus = byte
//                    } else if let command = AKMIDISystemCommand(rawValue: byte) {
//                        currentTypeByte = byte
//                        if command == .sysex || command == .sysexEnd {
//                            isParsingSysex = true
//                            runningStatus = nil
//                        }
//                    } else if AKMIDIMetaEventType(rawValue: byte) != nil {
//                        currentTypeByte = byte
//                        runningStatus = nil
//                    }
//                }
//                if isNotParsingMetaEvent && isNotParsingSysex {
//                    currentEventData.append(byte)
//                }
//            } else if currentLengthByte == nil {
//                if isParsingMetaEvent {
//                    currentLengthByte = byte
//                } else {
//                    if let type = currentTypeByte {
//                        if let command = AKMIDISystemCommand(rawValue: type) {
//                            currentLengthByte = MIDIByte(command.length ?? Int(byte))
//                        } else if let status = AKMIDIStatusType.from(byte: type) {
//                            currentLengthByte = MIDIByte(status.length)
//                        } else {
//                            AKLog("bad midi data - could not determine length of event", log: OSLog.midi)
//                            return events
//                        }
//                    } else {
//                        AKLog("bad midi data - could not determine type", log: OSLog.midi)
//                        return events
//                    }
//                    if isNotParsingSysex {
//                        currentEventData.append(byte)
//                    }
//                }
//            } else {
//                currentEventData.append(byte)
//            }
//            currentAllData.append(byte)
//            if let time = currentTime, let type = currentTypeByte, let length = currentLengthByte,
//                UInt8(currentEventData.count) == currentLengthByte {
//                var chunkEvent = AKMIDIFileChunkEvent(data: currentAllData, timeFormat: timeFormat,
//                                                      timeDivision: timeDivision, timeOffset: accumulatedDeltaTime)
//                if chunkEvent.typeByte == nil, let running = runningStatus {
//                    chunkEvent.runningStatus = AKMIDIStatus(byte: running)
//                }
//                if time != chunkEvent.deltaTime {
//                    AKLog("MIDI File Parser time mismatch \(time) vs. \(chunkEvent.deltaTime)", log: OSLog.midi)
//                    break
//                }
//                if type != chunkEvent.typeByte {
//                    AKLog("MIDI File Parser type mismatch \(type) vs. \(String(describing: chunkEvent.typeByte))", log: OSLog.midi)
//                    break
//                }
//                if length != chunkEvent.length {
//                    AKLog("MIDI File Parser length mismatch got \(length) expected \(chunkEvent.length) type: \(type)", log: OSLog.midi)
//                    break
//                }
//                accumulatedDeltaTime += chunkEvent.deltaTime
//                currentTime = nil
//                currentTypeByte = nil
//                currentLengthByte = nil
//                isParsingMetaEvent = false
//                isParsingSysex = false
//                currentEventData.removeAll()
//                currentAllData.removeAll()
//                events.append(chunkEvent)
//            }
//            currentByte += 1
        }
        return events
    }
}
