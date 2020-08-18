// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation

public struct AKMIDIFile {

    public var filename: String
    var chunks: [AKMIDIFileChunk] = []

    var headerChunk: MIDIFileHeaderChunk? {
        return chunks.first(where: { $0.isHeader }) as? MIDIFileHeaderChunk
    }

    public var trackChunks: [MIDIFileTrackChunk] {
        return Array(chunks.drop(while: { $0.isHeader && $0.isValid })) as? [MIDIFileTrackChunk] ?? []
    }

    public var tempoTrack: AKMIDIFileTempoTrack? {
        if format == 1, let tempoTrackChunk = trackChunks.first {
            return AKMIDIFileTempoTrack(trackChunk: tempoTrackChunk)
        }
        return nil
    }

    public var tracks: [AKMIDIFileTrack] {
        var tracks = trackChunks
        if format == 1 {
            tracks = Array(tracks.dropFirst()) // drop tempo track
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
        return headerChunk?.timeFormat
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
        filename = url.lastPathComponent
        if let midiData = try? Data(contentsOf: url) {
            let dataSize = midiData.count
            var chunks = [AKMIDIFileChunk]()
            var processedBytes = 0
            while processedBytes < dataSize {
                let data = Array(midiData.suffix(from: processedBytes))
                if let headerChunk = MIDIFileHeaderChunk(data: data) {
                    chunks.append(headerChunk)
                    processedBytes += headerChunk.rawData.count
                } else if let trackChunk = MIDIFileTrackChunk(data: data) {
                    chunks.append(trackChunk)
                    processedBytes += trackChunk.rawData.count
                }
            }
            self.chunks = chunks
        }
    }

    public init(path: String) {
        self.init(url: URL(fileURLWithPath: path))
    }
}

#endif
