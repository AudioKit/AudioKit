// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

#if !os(tvOS)

public protocol AKMIDITempoObserver {

    /// Called when a clock slave mode is entered and this client is not allowed to become a clock master
    /// This signifies that there is an incoming midi clock detected
    func midiClockLeaderMode()

    /// Called when this client is allowed to become a clock master
    func midiClockLeaderEnabled()

    /// Called each time the BPM is updated from the midi clock
    ///
    /// - Parameter bpm: Beats Per Minute
    func receivedTempo(bpm: BPMType, label: String)
}

public extension AKMIDITempoObserver {

    func midiClockLeaderMode() {

    }

    func midiClockLeaderEnabled() {

    }

    func receivedTempo(bpm: BPMType, label: String) {

    }

    func isEqualTo(_ listener: AKMIDITempoObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDITempoObserver, rhs: AKMIDITempoObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
