//
//  AKMIDIFileChunkEvent.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/7/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public struct AKMIDIFileChunkEvent {
    var data: [MIDIByte]
    var timeFormat: MIDITimeFormat
    var timeDivision: Int
    var runningStatus: AKMIDIStatus?
    private var timeOffset: Int //accumulated time from previous events

    init(data: [MIDIByte], timeFormat: MIDITimeFormat, timeDivision: Int, timeOffset: Int) {
        self.data = data
        self.timeFormat = timeFormat
        self.timeDivision = timeDivision
        self.timeOffset = timeOffset
    }

    var computedData: [MIDIByte] {
        var outData = [MIDIByte]()
        if let addStatus = runningStatus {
            outData.append(addStatus.byte)
        }
        outData.append(contentsOf: rawEventData)
        return outData
    }

    var rawEventData: [MIDIByte] {
        return Array(data.suffix(from: timeLength))
    }

    var deltaTime: Int {
        let timeBytes = data.prefix(timeLength)
        var time: UInt16 = 0
        for byte in timeBytes {
            let shifted: UInt16 = UInt16(time << 7)
            let masked: MIDIByte = byte & 0x7f
            time = shifted + UInt16(masked)
        }
        return Int(time)
    }

    var absoluteTime: Int {
        return deltaTime + timeOffset
    }

    var position: Double {
        return Double(absoluteTime) / Double(timeDivision)
    }

    var timeLength: Int {
        return (data.firstIndex(where: { $0 < 0x80 }) ?? 0) + 1
    }

    var typeByte: MIDIByte? {
        if let runningStatus = self.runningStatus {
            return runningStatus.byte
        }
        if let index = typeIndex {
            return data[index]
        }
        return nil
    }

    var typeIndex: Int? {
        if data.count > timeLength {
            if data[timeLength] == 0xFF,
                data.count > timeLength + 1 { //is Meta-Event
                return timeLength + 1
            } else if AKMIDIStatus(byte: data[timeLength]) != nil {
                return timeLength
            } else if AKMIDISystemCommand(rawValue: data[timeLength]) != nil {
                return timeLength
            }
        }
        return nil
    }

    var length: Int {
        if let metaEvent = event as? AKMIDIMetaEvent {
            return metaEvent.length
        } else if let status = event as? AKMIDIStatus {
            return status.length
        } else if let command = event as? AKMIDISystemCommand {
            if let standardLength = command.length {
                return standardLength
            } else if command == .sysex {
                return Int(data[timeLength + 1])
            } else {
                return data.count
            }
        } else if let index = typeIndex {
            return Int(data[index + 1])
        }
        return 0
    }

    var event: AKMIDIMessage? {
        if let meta = AKMIDIMetaEvent(data: rawEventData) {
            return meta
        } else if let type = typeByte {
            if let status = AKMIDIStatus(byte: type) {
                return status
            } else if let command = AKMIDISystemCommand(rawValue: type) {
                return command
            }
        }
        return nil
    }
}
