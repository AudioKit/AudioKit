// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// MIDI Tempo Observer
public protocol MIDITempoObserver {

    /// Called when a clock slave mode is entered and this client is not allowed to become a clock master
    /// This signifies that there is an incoming midi clock detected
    func midiClockLeaderMode()

    /// Called when this client is allowed to become a clock master
    func midiClockLeaderEnabled()

    /// Called each time the BPM is updated from the midi clock
    /// - Parameter bpm: Beats Per Minute
    func receivedTempo(bpm: BPMType, label: String)
}

public extension MIDITempoObserver {

    /// Called when a clock slave mode is entered and this client is not allowed to become a clock master
    /// This signifies that there is an incoming midi clock detected
    func midiClockLeaderMode() {
        // Do nothing
    }

    /// Called when this client is allowed to become a clock master
    func midiClockLeaderEnabled() {
        // Do nothing
    }

    /// Called each time the BPM is updated from the midi clock
    /// - Parameter bpm: Beats Per Minute
    func receivedTempo(bpm: BPMType, label: String) {
        // Do nothing
    }

    /// Equality test
    /// - Parameter other: Another listener
    func isEqual(to other: MIDITempoObserver) -> Bool {
        self == other
    }
}

func == (lhs: MIDITempoObserver, rhs: MIDITempoObserver) -> Bool {
    lhs.isEqual(to: rhs)
}
