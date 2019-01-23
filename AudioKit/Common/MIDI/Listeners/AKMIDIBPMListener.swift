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

    private var bpmObservers: [AKMIDIBPMObserver] = []

    public var bpmStr: String = ""
    public var bpm: BpmType = 0
    private var clockEvents: [UInt64] = []
    private let clockEventLimit = 2
    private var bpmStats = BpmHistoryStatistics()
    private var bpmAveraging: BpmHistoryAveraging
    private var timebaseInfo = mach_timebase_info()
    private var tickSmoothing: ValueSmoothing
    private var smoothedBpm = BpmType(0)

    private var clockTimeout: AKMIDITimeout?
    private var incomingClockActive = false

    private let BEAT_TICKS = 24
    private let oneThousand = UInt64(1000)

    @objc public init(smoothing: Float64 = 0.1, bpmHistoryLimit: Int = 192) {
        assert(bpmHistoryLimit > 0, "You must specify a positive number for bpmHistoryLimit")
        tickSmoothing = ValueSmoothing(factor: smoothing)
        bpmAveraging = BpmHistoryAveraging(countLimit: bpmHistoryLimit)

        beatEstimator = AKMIDIBeatEstimator(mmcListener: mmcListener, bpmListener: self)

        if timebaseInfo.denom == 0 {
            _ = mach_timebase_info(&timebaseInfo)
        }

        clockTimeout = AKMIDITimeout(timeoutInterval: 1.6, onMainThread: true, success: {}, timeout: {
            if self.incomingClockActive == true {
                self.midiClockActivityStopped()
            }
            self.incomingClockActive = false
        })
        midiClockActivityStopped()
    }

    deinit {
        clockTimeout = nil
        beatEstimator = nil
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
        if data[0] == AKMIDISystemCommand.clock.rawValue {
            clockTimeout?.succeed()
            clockTimeout?.perform {
                if self.incomingClockActive == false {
                    midiClockActivityStarted()
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

        let bpmCalc = BpmType((Float64(NSEC_PER_SEC) / Float64(intervalNanos) / Float64(BEAT_TICKS)) * Float64(60.0))
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

            bpmUpdate(bpmAveraging.results.avg, str: bpmStr)
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

// MARK: - Management and Communications for BPM Observers

extension AKMIDIBPMListener {
    public func addObserver(_ observer: AKMIDIBPMObserver) {
        bpmObservers.append(observer)
    }

    public func removeObserver(_ observer: AKMIDIBPMObserver) {
        bpmObservers.removeAll { $0 == observer }
    }

    public func removeAllObserver() {
        bpmObservers.removeAll()
    }

    func midiClockActivityStarted() {
        bpmObservers.forEach { (observer) in
            observer.midiClockSlaveMode()
        }
    }

    func midiClockActivityStopped() {
        bpmObservers.forEach { (observer) in
            observer.midiClockMasterEnabled()
        }
    }

    func bpmUpdate(_ bpm: BpmType, str: String) {
        bpmObservers.forEach { (observer) in
            observer.bpmUpdate(bpm, bpmStr: str)
        }
    }
}
