// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation
import CoreMIDI
import os.log

/// This class is used to count midi clock events and inform observers
/// every 24 pulses (1 quarter note)
///
/// If you wish to observer its events, then add your own AKMIDIBeatObserver
///
public class AKMIDIClockListener: NSObject {
    // Definition of 24 quantums per quarter note
    let quantumsPerQuarterNote: UInt8
    // Count of 24 quantums per quarter note
    public var quarterNoteQuantumCounter: UInt8 = 0
    // number of all time quantum F8 MIDI Clock messages seen
    public var quantumCounter: UInt64 = 0
    // 6 F8 MIDI Clock messages = 1 SPP MIDI Beat
    public var sppMIDIBeatCounter: UInt64 = 0
    // 6 F8 MIDI Clock quantum messages = 1 SPP MIDI Beat
    public var sppMIDIBeatQuantumCounter: UInt8 = 0
    // 1, 2, 3, 4 , 1, 2, 3, 4 - quarter note counter
    public var fourCount: UInt8 = 0

    private var sendStart = false
    private var sendContinue = false
    private let srtListener: AKMIDISystemRealTimeListener
    private let tempoListener: AKMIDITempoListener
    private var observers: [AKMIDIBeatObserver] = []

    /// AKMIDIClockListener requires to be an observer of both SRT and BPM events
    init(srtListener srt: AKMIDISystemRealTimeListener,
         quantumsPerQuarterNote count: UInt8 = 24,
         tempoListener tempo: AKMIDITempoListener) {
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
        sppMIDIBeatCounter = UInt64(positionPointer)
        quantumCounter = UInt64(6 * sppMIDIBeatCounter)
        quarterNoteQuantumCounter = UInt8(quantumCounter % 24)
    }

    func midiClockBeat(time: MIDITimeStamp) {
        self.quantumCounter += 1

        // quarter notes can only increment when we are playing
        guard srtListener.state == .playing else {
            sendQuantumUpdateToObservers(time: time)
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
            AKLog("\(prefix) \(fourCount)", log: OSLog.midi)

            if sendStart || sendContinue {
                sendStartContinueToObservers()
                sendContinue = false
                sendStart = false
            }

            sendQuarterNoteMessageToObservers()
        } else if quarterNoteQuantumCounter == quantumsPerQuarterNote {
            quarterNoteQuantumCounter = 0
        }
        sendQuantumUpdateToObservers(time: time)

        if sppMIDIBeatQuantumCounter == 6 { sppMIDIBeatQuantumCounter = 0; sppMIDIBeatCounter += 1 }
        sppMIDIBeatQuantumCounter += 1
        if sppMIDIBeatQuantumCounter == 1 {
            sendMIDIBeatUpdateToObservers()

            let beat = (sppMIDIBeatCounter % 16) + 1
            AKLog("       \(beat)", log: OSLog.midi)
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
        AKLog("[AKMIDIClockListener:addObserver] (\(observers.count) observers)", log: OSLog.midi)
    }

    public func removeObserver(_ observer: AKMIDIBeatObserver) {
        observers.removeAll { $0 == observer }
        AKLog("[AKMIDIClockListener:removeObserver] (\(observers.count) observers)", log: OSLog.midi)
    }

    public func removeAllObservers() {
        observers.removeAll()
    }
}

// MARK: - Beat Observations

extension AKMIDIClockListener: AKMIDIBeatObserver {
    internal func sendMIDIBeatUpdateToObservers() {
        observers.forEach { (observer) in
            observer.receivedBeatEvent(beat: sppMIDIBeatCounter)
        }
    }

    internal func sendQuantumUpdateToObservers(time: MIDITimeStamp) {
        observers.forEach { (observer) in
            observer.receivedQuantum(time: time,
                                     quarterNote: fourCount,
                                     beat: sppMIDIBeatCounter,
                                     quantum: quantumCounter)
        }
    }

    internal func sendQuarterNoteMessageToObservers() {
        observers.forEach { (observer) in
            observer.receivedQuarterNoteBeat(quarterNote: fourCount)
        }
    }

    internal func sendPreparePlayToObservers(continue resume: Bool) {
        observers.forEach { (observer) in
            observer.preparePlay(continue: resume)
        }
    }

    internal func sendStartContinueToObservers() {
        guard sendContinue || sendStart else { return }
        observers.forEach { (observer) in
            observer.startFirstBeat(continue: sendContinue)
        }
    }

    internal func sendStopToObservers() {
        observers.forEach { (observer) in
            observer.stopSRT()
        }
    }
}

// MARK: - MMC Observations interface

extension AKMIDIClockListener: AKMIDITempoObserver {

    public func midiClockFollowerMode() {
        AKLog("MIDI Clock Follower", log: OSLog.midi)
        quarterNoteQuantumCounter = 0
    }

    public func midiClockLeaderEnabled() {
        AKLog("MIDI Clock Leader Enabled", log: OSLog.midi)
        quarterNoteQuantumCounter = 0
    }
}

extension AKMIDIClockListener: AKMIDISystemRealTimeObserver {
    public func stopSRT(listener: AKMIDISystemRealTimeListener) {
        AKLog("Beat: [Stop]", log: OSLog.midi)
        sendStopToObservers()
    }

    public func startSRT(listener: AKMIDISystemRealTimeListener) {
        AKLog("Beat: [Start]", log: OSLog.midi)
        sppMIDIBeatCounter = 0
        quarterNoteQuantumCounter = 0
        fourCount = 0
        sendStart = true
        sendPreparePlayToObservers(continue: false)
    }

    public func continueSRT(listener: AKMIDISystemRealTimeListener) {
        AKLog("Beat: [Continue]", log: OSLog.midi)
        sendContinue = true
        sendPreparePlayToObservers(continue: true)
    }
}

#endif
