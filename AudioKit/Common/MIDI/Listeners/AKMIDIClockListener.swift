//
//  AKMIDIClockListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// This class is used to count midi clock events and inform observers
/// every 24 pulses (1 quarter note)
///
/// If you wish to observer its events, then add your own AKMIDIBeatObserver
///
open class AKMIDIClockListener: NSObject {
    // Definition of 24 quantums per quarter note
    let quantumsPerQuarterNote: UInt8
    // Count of 24 quantums per quarter note
    public var quarterNoteQuantumCounter: UInt8 = 0
    // number of all time quantum F8 MIDI Clock messages seen
    public var quantumCounter: UInt64 = 0
    // 6 F8 MIDI Clock messages = 1 SPP MIDI Beat
    public var sppMidiBeatCounter: UInt64 = 0
    // 6 F8 MIDI Clock quantum messages = 1 SPP MIDI Beat
    public var sppMidiBeatQuantumCounter: UInt8 = 0
    // 1, 2, 3, 4 , 1, 2, 3, 4 - quarter note counter
    public var fourCount: UInt8 = 0

    private var sendStart = false
    private var sendContinue = false
    private let srtListener: AKMIDISRTListener
    private let tempoListener: AKMIDITempoListener
    private var observers: [AKMIDIBeatObserver] = []

    /// AKMIDIClockListener requires to be an observer of both SRT and BPM events
    init(srtListener srt: AKMIDISRTListener, quantumsPerQuarterNote count: UInt8 = 24, tempoListener tempo: AKMIDITempoListener) {
        quantumsPerQuarterNote = count
        srtListener = srt
        tempoListener = tempo

        super.init()
        // self is now initialized

        srtListener.addObserver(self)
        tempoListener.addObserver(self)
    }

    deinit {
        srtListener.removeObserver(self)
        tempoListener.removeObserver(self)
        observers = []
    }

    func sppChange(_ positionPointer: UInt16) {
        sppMidiBeatCounter = UInt64(positionPointer)
        quantumCounter = UInt64(6 * sppMidiBeatCounter)
        quarterNoteQuantumCounter = UInt8(quantumCounter % 24)
    }

    func midiClockBeat() {
        self.quantumCounter += 1

        // quarter notes can only increment when we are playing
        guard srtListener.state == .playing else {
            sendQuantumUpdateToObservers()
            return
        }

        // increment quantum counter used for counting quarter notes
        self.quarterNoteQuantumCounter += 1

        // ever first quantum we will count as a quarter note event
        if quarterNoteQuantumCounter == 1 {
            // ever four quarter notes we reset
            if fourCount >= 4 { fourCount = 0 }
            fourCount += 1

            let spaces = "    "
            let prefix = spaces.prefix( Int(fourCount) )
            AKLog(prefix, fourCount)

            if (sendStart || sendContinue) {
                sendMmcStartContinueToObservers()
                sendContinue = false
                sendStart = false
            }

            sendQuarterNoteMessageToObservers()
        } else if quarterNoteQuantumCounter == quantumsPerQuarterNote {
            quarterNoteQuantumCounter = 0
        }
        sendQuantumUpdateToObservers()

        if sppMidiBeatQuantumCounter == 6 { sppMidiBeatQuantumCounter = 0; sppMidiBeatCounter += 1 }
        sppMidiBeatQuantumCounter += 1
        if (sppMidiBeatQuantumCounter == 1) {
            sendMIDIBeatUpdateToObservers()

            let beat = (sppMidiBeatCounter % 16) + 1
            AKLog("       ", beat)
        }
    }

    func midiClockStopped() {
        quarterNoteQuantumCounter = 0
        quantumCounter = 0
    }
}

// MARK: - Observers

extension AKMIDIClockListener {
    public func addObserver(_ observer: AKMIDIBeatObserver) {
        observers.append(observer)
//        AKLog("[AKMIDIClockListener:addObserver] (\(observers.count) observers)")
    }

    public func removeObserver(_ observer: AKMIDIBeatObserver) {
        observers.removeAll { $0 == observer }
//        AKLog("[AKMIDIClockListener:removeObserver] (\(observers.count) observers)")
    }

    public func removeAllObservers() {
        observers.removeAll()
//        AKLog("[AKMIDIClockListener:removeAllObservers] (\(observers.count) observers)")
    }
}

// MARK: - Beat Observations

extension AKMIDIClockListener: AKMIDITempoObserver {

    internal func sendMIDIBeatUpdateToObservers() {
//        AKLog("[sendQuantumUpdateToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDIBeatUpdate(beat: sppMidiBeatCounter)
        }
    }

    internal func sendQuantumUpdateToObservers() {
//        AKLog("[sendQuantumUpdateToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDIQuantumUpdate(quarterNote: fourCount, beat: sppMidiBeatCounter, quantum: quantumCounter)
        }
    }

    internal func sendQuarterNoteMessageToObservers() {
//        AKLog("[sendQuarterNoteMessageToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDIQuarterNoteBeat(quarterNote: fourCount)
        }
    }

    internal func sendMmcPreparePlayToObservers(continue resume: Bool) {
//        AKLog("[sendMmcPreparePlayToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDISRTPreparePlay(continue: resume)
        }
    }

    internal func sendMmcStartContinueToObservers() {
        guard sendContinue || sendStart else { return }
//        AKLog("[sendMmcStartContinueToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDISRTStartFirstBeat(continue: sendContinue)
        }
    }

    internal func sendMmcStopToObservers() {
//        AKLog("[sendMmcStopToObservers] (\(observers.count) observers)")
        observers.forEach { (observer) in
            observer.AKMIDISRTStop()
        }
    }
}

// MARK: - MMC Observations interface

extension AKMIDIClockListener: AKMIDISRTObserver {

    public func midiClockSlaveMode() {
        AKLog("[MIDI CLOCK SLAVE]")
        quarterNoteQuantumCounter = 0
    }

    public func midiClockMasterEnabled() {
        AKLog("[MIDI CLOCK MASTER - AVAILABLE]")
        quarterNoteQuantumCounter = 0
    }

    public func SRTStop(srtListener: AKMIDISRTListener) {
        AKLog("Beat: [Stop]")
        sendMmcStopToObservers()
    }

    public func SRTStart(srtListener: AKMIDISRTListener) {
        AKLog("Beat: [Start]")
        sppMidiBeatCounter = 0
        quarterNoteQuantumCounter = 0
        fourCount = 0
        sendStart = true
        sendMmcPreparePlayToObservers(continue: false)
    }

    public func SRTContinue(srtListener: AKMIDISRTListener) {
        AKLog("Beat: [Continue]")
        sendContinue = true
        sendMmcPreparePlayToObservers(continue: true)
    }
}
