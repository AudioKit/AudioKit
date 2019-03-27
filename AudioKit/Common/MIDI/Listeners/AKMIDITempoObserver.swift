//
//  AKMIDITempoObserver.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public protocol AKMIDITempoObserver {

    /// Called when a clock slave mode is entered and this client is not allowed to become a clock master
    /// This signifies that there is an incoming midi clock detected
    func midiClockSlaveMode()

    /// Called when this client is allowed to become a clock master
    func midiClockMasterEnabled()

    /// Called each time the BPM is updated from the midi clock
    ///
    /// - Parameter bpm: Beats Per Minute
    func receivedTempo(bpm: BPMType, label: String)
}

public extension AKMIDITempoObserver {

    func midiClockSlaveMode() {

    }

    func midiClockMasterEnabled() {

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
