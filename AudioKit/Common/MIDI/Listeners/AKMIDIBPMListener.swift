//
//  AKMIDIBPMListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/18/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  MIDI Spec
//      24 clocks/quarternote
//      96 clocks/4_beat_measure
//
//  Ideas
//      - Provide the standard deviation of differences in clock times to observe stability
//
//  Looked at
//      https://stackoverflow.com/questions/9641399/ios-how-to-receive-midi-tempo-bpm-from-host-using-coremidi
//      https://stackoverflow.com/questions/13562714/calculate-accurate-bpm-from-midi-clock-in-objc-with-coremidi
//      https://github.com/yderidde/PGMidi/blob/master/Sources/PGMidi/PGMidiSession.mm#L186


import Foundation
import CoreMIDI

public typealias BpmType = TimeInterval

open class AKMIDIBPMListener: AKMIDIListener {

    public var beatEstimator: AKMIDIBeatEstimator?

    public var mmcListener = AKMIDIMMCListener()

    public var bpmStr: String = ""
    public var bpm: BpmType = 0
    var clockEvents: [UInt64] = []
    let clockEventLimit = 2
    var bpmStats = BpmHistoryStatistics()
    var bpmAveraging: BpmHistoryAveraging
    var timebaseInfo = mach_timebase_info()
    var tickSmoothing: ValueSmoothing
    var smoothedBpm = BpmType(0)

    var clockTimeout: AKMIDITimeout?
    var incomingClockActive = false

    let BEAT_TICKS = 24
    let oneThousand = UInt64(1000)

    public init(smoothing: Float64 = 0.1, bpmHistoryLimit: Int = 192) {
        assert(bpmHistoryLimit > 0, "You must specify a positive number for bpmHistoryLimit")
        tickSmoothing = ValueSmoothing(factor: smoothing)
        bpmAveraging = BpmHistoryAveraging(countLimit: bpmHistoryLimit)

        beatEstimator = AKMIDIBeatEstimator(mmcListener: mmcListener)

        if timebaseInfo.denom == 0 {
            _ = mach_timebase_info(&timebaseInfo)
        }

        clockTimeout = AKMIDITimeout(timeoutInterval: 1.6, onMainThread: true, success: {}, timeout: {
//            AKLog("MIDI Clock Stopped")
            if self.incomingClockActive == true {
                self.mmcListener.midiClockStopped()
            }
            self.incomingClockActive = false
        })
        self.mmcListener.midiClockStopped()
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
        if data[0] == AKMIDISystemCommand.clock.rawValue {
//            AKLog("[MIDI Clock]")
            clockTimeout?.succeed()
            clockTimeout?.perform {
                if self.incomingClockActive == false {
//                    AKLog("MIDI Clock Started")
                    self.mmcListener.midiClockReceived()
                    self.incomingClockActive = true
                }
                clockEvents.append(time)
                analyze()
                beatEstimator?.midiClockBeat()
            }
        }
        if data[0] == AKMIDISystemCommand.stop.rawValue {
            resetClockEventsLeavingNone()
        }
        if data[0] == AKMIDISystemCommand.start.rawValue {
            resetClockEventsLeavingOne()
        }
        mmcListener.receivedMIDISystemCommand(data, time: time)
    }

    func clockEventDiffs() -> [UInt64] {
        let shifted = clockEvents.dropFirst()
        let zipped = zip(clockEvents, shifted)
        return zipped.map{ return $1 - $0 }
    }

    private func analyze() {
        guard clockEvents.count > 1 else { return }
        guard clockEventLimit > 1 else { return }
        guard clockEvents.count >= clockEventLimit else { return}

        let previousClockTime = clockEvents[ clockEvents.count - 2 ]
        let currentClockTime = clockEvents[ clockEvents.count - 1 ]

        guard previousClockTime > 0 && currentClockTime > previousClockTime else { return }

        let clockDelta = Float64(currentClockTime - previousClockTime)
        let tickDelta = tickSmoothing.smoothed(clockDelta)

        if timebaseInfo.denom == 0 {
            _ = mach_timebase_info(&timebaseInfo)
        }
        let intervalNanos = (UInt64(tickDelta) * UInt64(timebaseInfo.numer)) / (UInt64(oneThousand) * UInt64(timebaseInfo.denom))

        let bpmCalc = BpmType((Float64(1000000.0) / Float64(intervalNanos) / Float64(BEAT_TICKS)) * Float64(60.0))
        smoothedBpm = bpmCalc.roundToDecimalPlaces(2)

        resetClockEventsLeavingOne()

        bpmStats.recordBpm(smoothedBpm)

        let results = bpmStats.avgFromSmallestDeviatingHistory()

        // Only report results when there is enough history to guess at the BPM
        guard results.avg > 0 else { return }

        bpmAveraging.record(results.avg)
        bpm = bpmAveraging.results.avg

        let newBpmStr = String(format: "%3.2f", bpmAveraging.results.avg)
        if newBpmStr != bpmStr {
            bpmStr = newBpmStr
//            let stdDevStr = String(format: "%3.2f", bpmAveraging.results.std)
//            AKLog("BPM:", bpmStr,"\t\tstdDev: ", stdDevStr)
        }
    }

    private func resetClockEventsLeavingOne() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count-1).map { $0 }
    }

    private func resetClockEventsLeavingHalf() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count/2).map { $0 }
    }

    private func resetClockEventsLeavingNone() {
        guard clockEvents.count > 1 else { return }
        clockEvents = []
    }

}
