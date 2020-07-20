// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

public struct AKMIDIFileTempoTrack {

    public let track: AKMIDIFileTrack

    public var length: Double {
        return track.length
    }

    public var name: String? {
        return track.name
    }

    public var events: [AKMIDIEvent] {
        return track.events
    }

    public var metaEvents: [AKMIDIMetaEvent] {
        return track.metaEvents
    }

    init?(trackChunk: MIDIFileTrackChunk) {
        let tempoTrack = AKMIDIFileTrack(chunk: trackChunk)
        guard let tempoData = tempoTrack.metaEvents.first(where: { $0.type == .setTempo })?.data else {
            return nil
        }
        track = tempoTrack
        self.tempoData = tempoData
    }

    public var tempoData = [UInt8]()

    public var tempo: Float {
        let microsecondsPerSecond: Float = 60_000_000
        let int = tempoData.suffix(3).integerValue
        let value = Float(int ?? 500_000)
        return Float(Double(microsecondsPerSecond / value).roundToDecimalPlaces(4))
    }
}

#endif
