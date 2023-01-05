// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation

/// MIDI File
public struct MIDIFile {

    /// File name
    public var filename: String
    
    var chunks: [MIDIFileChunk] = []

    var headerChunk: MIDIFileHeaderChunk? {
        return chunks.first(where: { $0.isHeader }) as? MIDIFileHeaderChunk
    }

    /// Array of track chunks
    public var trackChunks: [MIDIFileTrackChunk] {
        return Array(chunks.drop(while: { $0.isHeader && $0.isValid })) as? [MIDIFileTrackChunk] ?? []
    }

    /// Optional tempo track
    public var tempoTrack: MIDIFileTempoTrack? {
        if format == 1, let tempoTrackChunk = trackChunks.first {
            return MIDIFileTempoTrack(trackChunk: tempoTrackChunk)
        }
        return nil
    }

    /// Array of MIDI File tracks
    public var tracks: [MIDIFileTrack] {
        var tracks = trackChunks
        if format == 1 {
            tracks = Array(tracks.dropFirst()) // drop tempo track
        }
        return tracks.compactMap({ MIDIFileTrack(chunk: $0) })
    }

    /// Format integer
    public var format: Int {
        return headerChunk?.format ?? 0
    }

    /// Track count
    public var trackCount: Int {
        return headerChunk?.trackCount ?? 0
    }

    /// MIDI Time format
    public var timeFormat: MIDITimeFormat? {
        return headerChunk?.timeFormat
    }

    /// Number of ticks per beat
    public var ticksPerBeat: Int? {
        return headerChunk?.ticksPerBeat
    }

    /// Number of frames per second
    public var framesPerSecond: Int? {
        return headerChunk?.framesPerSecond
    }

    /// Number of ticks per frame
    public var ticksPerFrame: Int? {
        return headerChunk?.ticksPerFrame
    }

    /// Time division to use
    public var timeDivision: UInt16 {
        return headerChunk?.timeDivision ?? 0
    }

    /// Initialize with a URL
    /// - Parameter url: URL to MIDI File
    public init(url: URL) {
        filename = url.lastPathComponent
        if let midiData = try? Data(contentsOf: url) {
            let dataSize = midiData.count
            var chunks = [MIDIFileChunk]()
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

    /// Initialize with a path
    /// - Parameter path: Path to MIDI FIle
    public init(path: String) {
        self.init(url: URL(fileURLWithPath: path))
    }
}

#endif
