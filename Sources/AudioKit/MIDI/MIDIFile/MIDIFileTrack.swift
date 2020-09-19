// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

#if !os(tvOS)

public struct MIDIFileTrack {

    var chunk: MIDIFileTrackChunk

    public var channelEvents: [MIDIEvent] {
        return chunk.chunkEvents.compactMap({ MIDIEvent(fileEvent: $0) }).filter({ $0.status?.data != nil })
    }

    public var events: [MIDIEvent] {
        return chunk.chunkEvents.compactMap({ MIDIEvent(fileEvent: $0) })
    }

    public var metaEvents: [MIDICustomMetaEvent] {
        return chunk.chunkEvents.compactMap({ MIDICustomMetaEvent(fileEvent: $0) })
    }

    public var length: Double {
        return metaEvents.last?.positionInBeats ?? 0
    }

    public var name: String? {
        if let nameChunk = chunk.chunkEvents.first(where: { $0.typeByte == MIDICustomMetaEventType.trackName.rawValue }),
            let meta = MIDICustomMetaEvent(data: nameChunk.computedData) {
            return meta.name
        }
        return nil
    }

    init(chunk: MIDIFileTrackChunk) {
        self.chunk = chunk
    }
}

#endif
