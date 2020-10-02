// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation
import AVFoundation

/// Protocol so that clients may observe beat events
public protocol MIDIBeatObserver {

    /// Called when the midi system real time start or continue message arrives.
    /// Will be called when on the very first beat.
    /// - Parameter continue: Whether or not to continue
    func preparePlay(continue: Bool)

    /// First beat of playback after an system real time start or continue message.
    /// This is called on the first clock tick after a start or continue command
    /// - Parameter continue: Whether or not to continue
    func startFirstBeat(continue: Bool)

    /// system real time stop message
    func stopSRT()

    /// Called each midi beat event (every 6 midi clock quantums)
    /// - Parameter beat: Current beat
    func receivedBeatEvent(beat: UInt64)

    /// Called each midi clock pulse (quantum = 24 quantums per quarter note)
    /// - Parameters:
    ///   - time: MIDI Time Stamp
    ///   - quarterNote: MIDI Byte
    ///   - beat: Beat as a UInt64
    ///   - quantum: 24 quantums per quarter note
    func receivedQuantum(time: MIDITimeStamp, quarterNote: MIDIByte, beat: UInt64, quantum: UInt64)

    /// Called each 24 midi clock pulses
    /// - Parameter quarterNote: MIDI Byte
    func receivedQuarterNoteBeat(quarterNote: MIDIByte)
}

/// Default listener methods
public extension MIDIBeatObserver {

    /// Called when the midi system real time start or continue message arrives.
    /// Will be called when on the very first beat.
    /// - Parameter continue: Whether or not to continue
    func preparePlay(continue: Bool) {
        // Do nothing
    }

    /// First beat of playback after an system real time start or continue message.
    /// This is called on the first clock tick after a start or continue command
    /// - Parameter continue: Whether or not to continue
    func startFirstBeat(continue: Bool) {
        // Do nothing
    }

    /// system real time stop message
    func stopSRT() {
        // Do nothing
    }

    /// Called each midi beat event (every 6 midi clock quantums)
    /// - Parameter beat: Current beat
    func receivedBeatEvent(beat: UInt64) {
        // Do nothing
    }

    /// Called each midi clock pulse (quantum = 24 quantums per quarter note)
    /// - Parameters:
    ///   - time: MIDI Time Stamp
    ///   - quarterNote: MIDI Byte
    ///   - beat: Beat as a UInt64
    ///   - quantum: 24 quantums per quarter note
    func receivedQuantum(time: MIDITimeStamp, quarterNote: MIDIByte, beat: UInt64, quantum: UInt64) {
        // Do nothing
    }

    /// Called each 24 midi clock pulses
    /// - Parameter quarterNote: MIDI Byte
    func receivedQuarterNoteBeat(quarterNote: MIDIByte) {
        // Do nothing
    }

    /// Equality test
    /// - Parameter listener: Another listener
    func isEqualTo(_ listener: MIDIBeatObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: MIDIBeatObserver, rhs: MIDIBeatObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}
#endif
