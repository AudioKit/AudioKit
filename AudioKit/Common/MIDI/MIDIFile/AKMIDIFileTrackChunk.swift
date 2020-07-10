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
        var runningStatus: MIDIByte?
        var processedBytes = 0
        while processedBytes < data.count {
            let subData = Array(data.suffix(from: processedBytes))
            let byte = data[processedBytes]
            if currentTimeVLQ == nil, let vlqTime = MIDIVariableLengthQuantity(fromBytes: subData) {
                currentTimeVLQ = vlqTime
                processedBytes += vlqTime.length
            } else if let vlqTime = currentTimeVLQ {
                var event: AKMIDIFileChunkEvent?
                if let metaEvent = AKMIDIMetaEvent(data: subData) {
                    let metaData = metaEvent.data
                    event = AKMIDIFileChunkEvent(data: vlqTime.data + metaData,
                                                     timeFormat: timeFormat, timeDivision: timeDivision,
                                                     timeOffset: accumulatedDeltaTime)
                    processedBytes += metaEvent.data.count
                    runningStatus = nil
                } else if let sysexEvent = MIDISysexMessage(bytes: subData) {
                    let sysexData = sysexEvent.data
                    event = AKMIDIFileChunkEvent(data:  vlqTime.data + sysexData,
                                                     timeFormat: timeFormat, timeDivision: timeDivision,
                                                     timeOffset: accumulatedDeltaTime)
                    processedBytes += sysexEvent.data.count
                    runningStatus = nil
                } else if let status = AKMIDIStatus(byte: byte) {
                    let messageLength = status.length
                    let chunkData = Array(subData.prefix(messageLength))
                    event = AKMIDIFileChunkEvent(data:  vlqTime.data + chunkData,
                                                     timeFormat: timeFormat, timeDivision: timeDivision,
                                                     timeOffset: accumulatedDeltaTime)
                    runningStatus = status.byte
                    processedBytes += messageLength
                } else if let activeRunningStatus = runningStatus, let status = AKMIDIStatus(byte: activeRunningStatus) {
                    let messageLength = status.length - 1 // drop one since running status is used
                    let chunkData = Array(subData.prefix(messageLength))
                    event = AKMIDIFileChunkEvent(data:  vlqTime.data + chunkData,
                                                     timeFormat: timeFormat, timeDivision: timeDivision,
                                                     timeOffset: accumulatedDeltaTime, runningStatus: status)
                    processedBytes += messageLength
                } else {
                    fatalError("error parsing midi file - byte is \(byte), processed \(processedBytes) of \(data.count)")
                }
                guard let currentEvent = event else { break }
                events.append(currentEvent)
                accumulatedDeltaTime += Int(vlqTime.quantity)
                currentTimeVLQ = nil
            }
        }
        return events
    }
}
