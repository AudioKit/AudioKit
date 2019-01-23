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

    /// Called when the midi mmc start or continue message arrives.
    /// AKMidiMmcStartFirstBeat(continue:) will be
    // called when on the very first beat.
    func AKMidiMmcPreparePlay(continue: Bool)

    /// First beat of playback after an mmc start or continue message.
    func AKMidiMmcStartFirstBeat(continue: Bool)

    /// mmc stop message
    func AKMidiMmcStop()

    /// Called each 24 midi clock pulses
    func AKMidiQuarterNoteBeat()
}

/// Default listener methods
public extension AKMIDIBeatObserver {

    func AKMidiMmcPreparePlay(continue: Bool) {

    }

    func AKMidiMmcStartFirstBeat(continue: Bool) {

    }

    func AKMidiMmcStop() {

    }

    func AKMidiQuarterNoteBeat() {

    }

    func isEqualTo(_ listener : AKMIDIBeatObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIBeatObserver, rhs: AKMIDIBeatObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}

