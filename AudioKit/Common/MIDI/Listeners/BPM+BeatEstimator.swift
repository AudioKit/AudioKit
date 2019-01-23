//
//  BPM+BeatEstimator.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// This class is used to count midi clock events and inform listeners
/// every 24 pulses (1 quarter note)
/// The reason this is called an estimator, is that before an mmc start
/// command is received, the guarter note events are just guesses based
/// on the very first clock event received.
///
/// AKMIDIBeatEstimator requires to be an observer of both MMC and BPM events
open class AKMIDIBeatEstimator : AKMIDIMMCObserver, AKMIDIBPMObserver  {
    public var beatCounter: UInt64 = 0
    public var fourCount: UInt8 = 0
    let quarterNoteCount: UInt8
    private var sendStart = false
    private var sendContinue = false

    private let mmcListener: AKMIDIMMCListener
    private let bpmListener: AKMIDIBPMListener
    private var listeners: [AKMIDIBeatObserver] = []

    init(mmcListener mmc: AKMIDIMMCListener, quarterNoteCount count: UInt8 = 24, bpmListener bpm: AKMIDIBPMListener) {
        quarterNoteCount = count
        mmcListener = mmc
        bpmListener = bpm

        // self is now initializedI
        
        mmcListener.addObserver(self)
        bpmListener.addObserver(self)
    }

    deinit {
        mmcListener.removeObserver(self)
        bpmListener.removeObserver(self)
        listeners = []
    }

    func addListener(listener: AKMIDIBeatObserver) {
        listeners.append(listener)
    }

    func removedListener(listener: AKMIDIBeatObserver) {
        listeners.removeAll { $0 == listener }
    }

    func removedAllListeners() {
        listeners.removeAll()
    }

    func midiClockBeat() {
        guard mmcListener.state == .playing else { return }

        self.beatCounter += 1

        if beatCounter == 1 {
            fourCount += 1
            if fourCount > 4 { fourCount = 1 }
            if fourCount > 0 { AKLog("Beat: ", fourCount) }

            if sendStart || sendContinue {
                sendMmcStartContinueToListeners()
                sendContinue = false
                sendStart = false
            }

            sendQuarterNoteMessageToListeners()
        } else if beatCounter == 24 {
            beatCounter = 0
        }
    }

    func midiClockStopped() {
        beatCounter = 0
    }
}

// MARK: - Send to Listeners

extension AKMIDIBeatEstimator {
    private func sendQuarterNoteMessageToListeners() {
        listeners.forEach { (listener) in
            listener.AKMidiQuarterNoteBeat()
        }
    }

    private func sendMmcPreparePlayToListeners(continue resume: Bool) {
        listeners.forEach { (listener) in
            listener.AKMidiMmcPreparePlay(continue: resume)
        }
    }

    func sendMmcStartContinueToListeners() {
        guard sendContinue || sendStart else { return }

        listeners.forEach { (listener) in
            listener.AKMidiMmcStartFirstBeat(continue: sendContinue)
        }
    }

    private func sendMmcStopToListeners() {
        listeners.forEach { (listener) in
            listener.AKMidiMmcStop()
        }
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
        sendMmcStopToListeners()
    }

    public func mmcStart(state newState: AKMIDIMMCListener.mmc_state) {
        AKLog("Beat: [Start]")
        beatCounter = 0
        fourCount = 0
        sendStart = true
        sendMmcPreparePlayToListeners(continue: true)
    }

    public func mmcContinue(state newState: AKMIDIMMCListener.mmc_state) {
        AKLog("Beat: [Continue]")
        sendContinue = true
        sendMmcPreparePlayToListeners(continue: true)
    }
}
