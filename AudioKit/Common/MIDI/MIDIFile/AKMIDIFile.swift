//
//  AKMIDIFile.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/5/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public struct AKMIDIFile {

    var chunks: [AKMIDIFileChunk] = []

    var headerChunk: MIDIFileHeaderChunk? {
        return chunks.first(where: { $0.isHeader }) as? MIDIFileHeaderChunk
    }

    var trackChunks: [MIDIFileTrackChunk] {
        return Array(chunks.drop(while: { $0.isHeader && $0.isValid })) as? [MIDIFileTrackChunk] ?? []
    }

    public var tempoTrack: AKMIDIFileTrack? {
        if format == 1, let tempoTrackChunk = trackChunks.first {
            return AKMIDIFileTrack(chunk: tempoTrackChunk)
        }
        return nil
    }

    public var tracks: [AKMIDIFileTrack] {
        var tracks = trackChunks
        if format == 1 {
            tracks = Array(tracks.dropFirst())
        }
        return tracks.compactMap({ AKMIDIFileTrack(chunk: $0) })
    }

    public var format: Int {
        return headerChunk?.format ?? 0
    }

    public var numberOfTracks: Int {
        return headerChunk?.numTracks ?? 0
    }

    public var timeFormat: MIDITimeFormat? {
        return headerChunk?.timeFormat ?? nil
    }

    public var ticksPerBeat: Int? {
        return headerChunk?.ticksPerBeat
    }

    public var framesPerSecond: Int? {
        return headerChunk?.framesPerSecond
    }

    public var ticksPerFrame: Int? {
        return headerChunk?.ticksPerFrame
    }

    public var timeDivision: UInt16 {
        return headerChunk?.timeDivision ?? 0
    }

    public init(url: URL) {
        if let midiData = try? Data(contentsOf: url) {
            let dataSize = midiData.count
            let typeLength = 4
            var typeIndex = 0
            let sizeLength = 4
            var sizeIndex = 0
            var dataLength: UInt32 = 0
            var chunks = [AKMIDIFileChunk]()
            var currentTypeChunk: [UInt8] = Array(repeating: 0, count: 4)
            var currentLengthChunk: [UInt8] = Array(repeating: 0, count: 4)
            var currentDataChunk: [UInt8] = []
            var newChunk = true
            var isParsingType = false
            var isParsingLength = false
            var isParsingHeader = true
            for i in 0..<dataSize {
                if newChunk {
                    isParsingType = true
                    isParsingLength = false
                    newChunk = false
                    currentTypeChunk = Array(repeating: 0, count: 4)
                    currentLengthChunk = Array(repeating: 0, count: 4)
                    currentDataChunk = []
                }
                if isParsingType { //get chunk type
                    currentTypeChunk[typeIndex] = midiData[i]
                    typeIndex += 1
                    if typeIndex == typeLength {
                        isParsingType = false
                        isParsingLength = true
                        typeIndex = 0
                    }
                } else if isParsingLength { //get chunk length
                    currentLengthChunk[sizeIndex] = midiData[i]
                    sizeIndex += 1
                    if sizeIndex == sizeLength {
                        isParsingLength = false
                        sizeIndex = 0
                        dataLength = MIDIHelper.convertTo32Bit(msb: currentLengthChunk[0], data1: currentLengthChunk[1],
                                                    data2: currentLengthChunk[2], lsb: currentLengthChunk[3])
                    }
                } else { //get chunk data
                    var tempChunk: AKMIDIFileChunk
                    currentDataChunk.append(midiData[i])
                    if UInt32(currentDataChunk.count) == dataLength {
                        if isParsingHeader {
                            tempChunk = MIDIFileHeaderChunk(typeData: currentTypeChunk,
                                                            lengthData: currentLengthChunk, data: currentDataChunk)
                        } else {
                            tempChunk = MIDIFileTrackChunk(typeData: currentTypeChunk,
                                                           lengthData: currentLengthChunk, data: currentDataChunk)
                        }
                        newChunk = true
                        isParsingHeader = false
                        chunks.append(tempChunk)
                    }
                }
            }
            self.chunks = chunks
        }
    }

    public init(path: String) {
        self.init(url: URL(fileURLWithPath: path))
    }
}
