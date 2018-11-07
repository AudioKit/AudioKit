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
                }
            } else if let status = AKMIDIStatus(byte: typeByte) {
                if let type = status.type {
                    return type.length
                }
            } else if let command = AKMIDISystemCommand(rawValue: typeByte) {
                return command.length ?? 0
            }
        } else if let index = typeIndex {
            return Int(data[index + 1])
        }
        return 0
    }
}
