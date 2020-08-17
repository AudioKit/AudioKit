// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation
import AVFoundation

/// Protocol so that clients may observe beat events
public protocol AKMIDIBeatObserver {

    /// Called when the midi system real time start or continue message arrives.
    /// Will be called when on the very first beat.
    func preparePlay(continue: Bool)

    /// First beat of playback after an system real time start or continue message.
    /// This is called on the first clock tick after a start or continue command
    func startFirstBeat(continue: Bool)

    /// system real time stop message
    func stopSRT()

    /// Called each midi beat event (every 6 midi clock quantums)
    func receivedBeatEvent(beat: UInt64)

    /// Called each midi clock pulse (quantum = 24 quantums per quarter note)
    func receivedQuantum(time: MIDITimeStamp, quarterNote: UInt8, beat: UInt64, quantum: UInt64)

    /// Called each 24 midi clock pulses
    func receivedQuarterNoteBeat(quarterNote: UInt8)
}

/// Default listener methods
public extension AKMIDIBeatObserver {

    func preparePlay(continue: Bool) {

    }

    func startFirstBeat(continue: Bool) {

    }

    func stopSRT() {

    }

    func receivedBeatEvent(beat: UInt64) {

    }

    func receivedQuantum(time: MIDITimeStamp, quarterNote: UInt8, beat: UInt64, quantum: UInt64) {

    }

    func receivedQuarterNoteBeat(quarterNote: UInt8) {

    }

    func isEqualTo(_ listener: AKMIDIBeatObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIBeatObserver, rhs: AKMIDIBeatObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}
#endif
