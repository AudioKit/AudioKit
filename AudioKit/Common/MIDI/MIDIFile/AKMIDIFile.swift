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
    var header: MIDIFileHeaderChunk? {
        return chunks.first(where: { $0.isHeader }) as? MIDIFileHeaderChunk
    }
    var trackChunks: [MIDIFileTrackChunk] {
        return Array(chunks.drop(while: { $0.isHeader && $0.isValid })) as? [MIDIFileTrackChunk] ?? []
    }

    init(path: String) {
        print("loadind file at \(path)")
        let url = URL(fileURLWithPath: path)
        if let midiData = try? Data(contentsOf: url) {
            print("got data \(midiData.count)")
            let dataSize = midiData.count
            let typeLength = 4
            var typeIndex = 0
            let sizeLength = 4
            var sizeIndex = 0
            var dataLength = 0
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
                        dataLength = Int(currentLengthChunk.map(String.init).joined()) ?? 0
                    }
                } else { //get chunk data
                    var tempChunk: AKMIDIFileChunk
                    currentDataChunk.append(midiData[i])
                    if UInt8(currentDataChunk.count) == dataLength {
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
}
