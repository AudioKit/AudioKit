//
//  AKMIDITrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 3/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public struct AKMIDITrack {

    var chunk: MIDIFileTrackChunk
    
    public var events: [AKMIDIEvent] {
        return chunk.chunkEvents.compactMap({ AKMIDIEvent(fileEvent: $0) })
    }

    init(chunk: MIDIFileTrackChunk) {
        self.chunk = chunk
    }

    public var name: String? {
        if let nameChunk = chunk.chunkEvents.first(where: { $0.typeByte == AKMIDIMetaEventType.trackName.rawValue }),
            let meta = AKMIDIMetaEvent(data: nameChunk.computedData) {
            return meta.name
        }
        return nil
    }
}
