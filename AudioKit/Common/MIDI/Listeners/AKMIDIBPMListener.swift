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
import CoreMIDI

public typealias BpmType = TimeInterval

extension Array where Element: FloatingPoint {

    func sum() -> Element {
        return self.reduce(0, +)
    }

    func avg() -> Element {
        return self.sum() / Element(self.count)
    }

    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }

}

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
    public var bpm: BpmType = 0
    public var bpmHistory: [BpmType] = []
    let bpmHistoryLimit = 4
    var convert = 117.54

    public init() {

    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
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
            resetClockEvents()
        }
        if data[0] == AKMIDISystemCommand.continue.rawValue {
            AKLog("Incoming MMC [Continue]")
            let newState = state.event(event: .continue)
            state = newState
        }
        if data[0] == AKMIDISystemCommand.clock.rawValue {
            let nanos = AudioConvertHostTimeToNanos(time)
            clockEvents.append(nanos)
            analyze()
        }
    }

    func clockEventDiffs() -> [UInt64] {
        let shifted = clockEvents.dropFirst()
        let zipped = zip(clockEvents, shifted)
        return zipped.map{ return $1 - $0 }
    }
    
    private func analyze() {
        guard clockEvents.count > 1 else { return }
        guard bpmHistoryLimit > 1 else { return }
        guard clockEventLimit > 1 else { return }

        guard clockEvents.count >= clockEventLimit else { return}

        // https://stackoverflow.com/questions/9641399/ios-how-to-receive-midi-tempo-bpm-from-host-using-coremidi
        // https://stackoverflow.com/questions/13562714/calculate-accurate-bpm-from-midi-clock-in-objc-with-coremidi
        // https://github.com/yderidde/PGMidi/blob/master/Sources/PGMidi/PGMidiSession.mm#L186
        // (1000 / 17.86 / 24) * 60 = 139.978 BPM
        // This doesn't seem to work correctly.  I'm fine tuning the 60 second duration to see what effect it has.
        // 156 BPM on my Red Voyage 1 registers as 156.83 in Ableton and I want my reading to match Ableton

        // Idea : Weighted mean where recent ticks get more weight in the mean calculation

        let diffNanos24ticks = TimeInterval(clockEvents[clockEventLimit-1] - clockEvents[0])
        let time = TimeInterval(NSEC_PER_SEC) / diffNanos24ticks // (TimeInterval(24) / TimeInterval(clockEventLimit))
         //0.7916033333 * 60 * 5
        let bpmCalc =  TimeInterval(convert) * time
        resetClockEvents()

        while bpmHistory.count > (bpmHistoryLimit - 1) {
            bpmHistory.remove(at: 0)
        }
        bpmHistory.append(bpmCalc)
        bpm = bpmCalc

        AKLog("BPM: \(bpmCalc) mean: \(bpmHistory.avg()) stdDev: \(bpmHistory.std())")
    }

    private func resetClockEvents() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count-1).map { $0 }
    }
}
