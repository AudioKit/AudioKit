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
        var events = [AKMIDIFileChunkEvent]()
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
        }
        return events
    }
}
