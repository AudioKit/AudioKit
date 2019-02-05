//
//  AKMIDIBeatObserver.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

/// Protocol so that clients may observe beat events
public protocol AKMIDIBeatObserver {

    /// Called when the midi system real time start or continue message arrives.
    /// AKMidiMmcStartFirstBeat(continue:) will be
    // called when on the very first beat.
    func AKMIDISRTPreparePlay(continue: Bool)

    /// First beat of playback after an system real time start or continue message.
    func AKMIDISRTStartFirstBeat(continue: Bool)

    /// system real time stop message
    func AKMIDISRTStop()

    /// Called each midi beat event (every 6 midi clock quantums)
    func AKMIDIBeatUpdate(beat: UInt64)

    /// Called each midi clock pulse (quantum = 24 quantums per quarter note)
    func AKMIDIQuantumUpdate(quarterNote: UInt8, beat: UInt64, quantum: UInt64)

    /// Called each 24 midi clock pulses
    func AKMIDIQuarterNoteBeat(quarterNote: UInt8)
}

/// Default listener methods
public extension AKMIDIBeatObserver {

    func AKMIDISRTPreparePlay(continue: Bool) {

    }

    func AKMIDISRTStartFirstBeat(continue: Bool) {

    }

    func AKMIDISRTStop() {

    }

    func AKMIDIBeatUpdate(beat: UInt64) {

    }

    func AKMIDIQuantumUpdate(quarterNote: UInt8, beat: UInt64, quantum: UInt64) {

    }

    func AKMIDIQuarterNoteBeat(quarterNote: UInt8) {

    }

    func isEqualTo(_ listener : AKMIDIBeatObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIBeatObserver, rhs: AKMIDIBeatObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}

