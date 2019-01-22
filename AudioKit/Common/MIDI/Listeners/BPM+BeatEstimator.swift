//
//  BPM+BeatEstimator.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

// MARK: - AKMIDIMMCEventsListener interface

public protocol AKMIDIBeatEventListener {

    /// Called each 24 midi clock pulses
    func quarterNoteBeat()
}

/// Default listener functions
public extension AKMIDIBeatEventListener {

    func quarterNoteBeat() {

    }

    func isEqualTo(_ listener : AKMIDIBeatEventListener) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIBeatEventListener, rhs: AKMIDIBeatEventListener) -> Bool {
    return lhs.isEqualTo(rhs)
}

/// This class is used to count midi clock events and inform listeners
/// every 24 pulses (1 quarter note)
/// The reason this is called an estimator, is that before an mmc start
/// command is received, the guarter note events are just guesses based
/// on the very first clock event received
open class AKMIDIBeatEstimator : AKMIDIMMCEventsListener  {
    var beatCounter: UInt64 = 0
    var listeners: [AKMIDIBeatEventListener] = []
    let quarterNoteCount: UInt8
    let mmcListener: AKMIDIMMCListener
    var fourCount: UInt8 = 0
    private var state: AKMIDIMMCListener.mmc_state = .stopped

    init(mmcListener mmc: AKMIDIMMCListener, quarterNoteCount count: UInt8 = 24) {
        quarterNoteCount = count
        mmcListener = mmc
        mmc.addListener(self)
    }

    func addListener(listener: AKMIDIBeatEventListener) {
        listeners.append(listener)
    }

    func removedListener(listener: AKMIDIBeatEventListener) {
        listeners.removeAll { $0 == listener }
    }

    func midiClockBeat() {
        guard state == .playing else { return }

        self.beatCounter += 1

        if beatCounter == 1 {
            fourCount += 1
            if fourCount > 4 { fourCount = 1 }
            if fourCount > 0 { AKLog("Beat: ", fourCount) }

            listeners.forEach { (listener) in
                listener.quarterNoteBeat()
            }
        } else if beatCounter == 24 {
            beatCounter = 0
        }
    }

    func midiClockStopped() {
        beatCounter = 0
    }
}

// MARK: - AKMIDIMMCEventsListener interface

extension AKMIDIBeatEstimator  {

    public func midiClockSlaveMode() {
        AKLog("[MIDI CLOCK SLAVE]")
        beatCounter = 0
    }

    public func midiClockMasterEnabled() {
        AKLog("[MIDI CLOCK MASTER - AVAILABLE]")
        beatCounter = 0
    }

    public func mmcStop(state newState: AKMIDIMMCListener.mmc_state) {
        AKLog("Beat: [Stop]")
        state = newState
    }

    public func mmcStart(state newState: AKMIDIMMCListener.mmc_state) {
        AKLog("Beat: [Start]")
        beatCounter = 0
        fourCount = 0
        state = newState
    }

    public func mmcContinue(state newState: AKMIDIMMCListener.mmc_state) {
        AKLog("Beat: [Continue]")
        state = newState
    }
}
