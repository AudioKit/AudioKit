//
//  AKMIDIFileTrackChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public struct MIDIFileTrackChunk: AKMIDIFileChunk {

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

    public var chunkEvents: [AKMIDIFileChunkEvent] {
        var events = [AKMIDIFileChunkEvent]()
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
        var i = 0
        print("data \(data)")
        for byte in data {
            print("processing \(i) - \(byte.hex) - \(byte)")
            i += 1
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
                        print("setting variable time to \(currentTimeByte)")
                        isParsingVariableTime = false
                    } else {
                        currentTimeByte = Int(byte)
                        print("setting time to \(currentTimeByte)")
                    }
                }
            } else if currentTypeByte == nil {
                if byte == 0xFF { //MetaEvent
                    print("isParsingMetaEvent now")
                    isParsingMetaEvent = true
                } else {
                    if let _ = AKMIDIStatusType.from(byte: byte) {
                        currentTypeByte = byte
                        runningStatus = byte
                        print("type is status")
                    } else if AKMIDISystemCommand(rawValue: byte) != nil {
                        currentTypeByte = byte
                        print("type is command")
                    } else if AKMIDIMetaEventType(rawValue: byte) != nil {
                        currentTypeByte = byte
                        print("type is meta")
                    } else if let statusByte = runningStatus, let status = AKMIDIStatusType.from(byte: statusByte) {
                        let length = MIDIByte(status.length)
                        currentTypeByte = statusByte
                        currentEventData.append(statusByte)
                        currentLengthByte = length
                        print("running status")
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
                    print("setting length to \(currentLengthByte) from meta")
                } else {
                    if let type = currentTypeByte {
                        if let command = AKMIDISystemCommand(rawValue: type) {
                            currentLengthByte = MIDIByte(command.length ?? Int(byte))
                            print("setting length to \(currentLengthByte) from command")
                        } else if let status = AKMIDIStatusType.from(byte: type) {
                            currentLengthByte = MIDIByte(status.length)
                            print("setting length to \(currentLengthByte) from status")
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
                print("Got all needed events for event fo type \(currentTypeByte) currentAllData \(currentAllData)")
                var chunkEvent = AKMIDIFileChunkEvent(data: currentAllData)
                if chunkEvent.typeByte == nil, let running = runningStatus {
                    chunkEvent.runningStatus = AKMIDIStatus(byte: running)
                }
                if time != chunkEvent.deltaTime {
                    AKLog("MIDI File Parser time mismatch \(time) vs. \(chunkEvent.deltaTime)")
                    break
                }
                if type != chunkEvent.typeByte {
                    AKLog("MIDI File Parser type mismatch \(type) vs. \(String(describing: chunkEvent.typeByte))")
                    break
                }
                if length != chunkEvent.length {
                    AKLog("MIDI File Parser length mismatch got \(length) expected \(chunkEvent.length) type: \(type)")
                    break
                }
                currentTimeByte = nil
                currentTypeByte = nil
                currentLengthByte = nil
                isParsingMetaEvent = false
                isParsingSysex = false
                currentEventData.removeAll()
                variableBits.removeAll()
                currentAllData.removeAll()

                events.append(chunkEvent)
            }
        }
        return events
    }
}
