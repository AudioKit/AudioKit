//
//  AKMIDIBPMListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/18/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  MIDI Spec
//      60 bpm = 24 clocks/quarternote = 60 quarternotes/minute
//      1 quarternote = 1 second = 24 clocks
//      60/24 = 2.5
//
//  Ideas
//      - Provide the standard deviation of differences in clock times to observe stability

import Foundation

open class AKMIDIBPMListener: AKMIDIListener {

    enum mmc_event: MIDIByte {
        case stop = 0xFC
        case start = 0xFA
        case `continue` = 0xFB
    }

    enum mmc_state {
        case stopped
        case playing
        case paused

        func event(event: mmc_event) -> mmc_state {
            switch self {
            case .stopped:
                switch event {
                case .start:
                    return .playing
                case .stop:
                    return .stopped
                case .continue:
                    return .playing
                }
            case .playing:
                switch event {
                case .start:
                    return .playing
                case .stop:
                    return .paused
                case .continue:
                    return .playing
                }
            case .paused:
                switch event {
                case .start:
                    return .playing
                case .stop:
                    return .stopped
                case .continue:
                    return .playing
                }
            }
        }
    }

    var state: mmc_state = .stopped

    var clockEvents: [UInt64] = []
    let clockEventLimit = 48
    var info = mach_timebase_info()
    public var bpm: Float64 = 0
    public var bpmHistory: [Float64] = []
    let bpmHistoryLimit = 96

    public init() {
        guard mach_timebase_info(&info) == KERN_SUCCESS else {
            return
        }
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        if data[0] == AKMIDISystemCommand.stop.rawValue {
            AKLog("Incoming MMC [Stop]")
            let newState = state.event(event: .stop)
            state = newState
        }
        if data[0] == AKMIDISystemCommand.start.rawValue {
            AKLog("Incoming MMC [Start]")
            let newState = state.event(event: .start)
            state = newState

            // if you want bpm updates to be synchronized to quarter notes, then uncomment this next line
            // synchronized updates could sound more musical possibly?
//            clockEvents = []
        }
        if data[0] == AKMIDISystemCommand.continue.rawValue {
            AKLog("Incoming MMC [Continue]")
            let newState = state.event(event: .continue)
            state = newState
        }
        if data[0] == AKMIDISystemCommand.clock.rawValue {
            let eventTime = mach_absolute_time()
            clockEvents.append(eventTime)
            analyze()
            expireOldestClockEvents()
        }
    }

    func clockEventDiffs() -> [UInt64] {
        let shifted = clockEvents.dropFirst()
        let zipped = zip(clockEvents, shifted)
        return zipped.map{ return $1 - $0 }
    }
    
    private func analyze() {
        guard clockEvents.count > 1 else { return }

        // expireOldest() ensures that we always arrive here with 24 or less clockEvents
        let clockEventDiffs = self.clockEventDiffs()
        let times = clockEventDiffs.map { (timediff) -> Float64 in
            let pulseTime =  Float64( (UInt32(timediff) * info.numer / info.denom) ) / Float64(NSEC_PER_SEC)
            let pulsesPerMinute =  Float64(60) / pulseTime
            let bpm = pulsesPerMinute / Float64(23)
            return bpm
        }
        // Average the pulse times
        let bpmCalc = times.reduce(0) { $0 + $1 } / times.count
        while bpmHistory.count > (bpmHistoryLimit - 1) {
            bpmHistory.remove(at: 0)
        }
        bpmHistory.append(bpmCalc)

//        AKLog("bpmCalc: \(bpmCalc) based on \(times.count) timed clock pulses\n - \(bpmHistory.count) bpm's in history\n - \(clockEvents.count) clock events")

        // Eventually we will use stdev to see when the bpm accurancy has stabilized
        if clockEvents.count > (clockEventLimit - 1) {
            let bpmAvg = bpmHistory.reduce(0) { $0 + $1 } / bpmHistory.count
            bpm = bpmAvg
        }
    }

    private func expireOldestClockEvents() {
        guard clockEvents.count > (clockEventLimit - 1) else { return }
        clockEvents = []
    }
}
