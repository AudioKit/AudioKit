// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

#if !os(tvOS)
import Foundation
import CoreMIDI

public typealias BPMType = TimeInterval

/// A AudioKit midi listener that looks at midi clock messages and calculates a BPM
///
/// Usage:
///
///     let tempoListener = AKMIDITempoListener()
///     AKMIDI().addListener(tempoListener)
///
/// Make your class a AKMIDITempoObserver and you will recieve callbacks when the BPM
/// changes.
///
///     class YOURCLASS: AKMIDITempoObserver {
///         func receivedTempoUpdate(bpm: BPMType, label: String) {  ... }
///         func midiClockFollowerMode() { ... }
///         func midiClockLeaderEnabled() { ... }
///
/// midiClockFollowerMode() informs client that midi clock messages have been received
/// and the client may not become the clock leader.  The client must stop all
/// transmission of MIDI clock.
///
/// midiClockLeaderEnabled() informs client that midi clock messages have not been seen
/// in 1.6 seconds and the client is allowed to become the clock leader.
///
public class AKMIDITempoListener: NSObject {

    public var clockListener: AKMIDIClockListener?

    public var srtListener = AKMIDISystemRealTimeListener()

    var tempoObservers: [AKMIDITempoObserver] = []

    public var tempoString: String = ""
    public var tempo: BPMType = 0
    var clockEvents: [UInt64] = []
    let clockEventLimit = 2
    var bpmStats = BPMHistoryStatistics()
    var bpmAveraging: BPMHistoryAveraging
    var timebaseInfo = mach_timebase_info()
    var tickSmoothing: ValueSmoothing
    var bpmSmoothing: ValueSmoothing

    var clockTimeout: AKMIDITimeout?
    public var incomingClockActive = false

    let BEAT_TICKS = 24
    let oneThousand = UInt64(1_000)

    /// Create a BPM Listener
    ///
    /// This object creates a clockListener: AKMIDIClockListener
    /// The AKMIDIClockListener is informed every time there is a clock and it in turn informs its
    /// AKMIDIBeatObserver's whenever beat events happen.
    ///
    /// - Parameters:
    ///   - smoothing: [0 - 1] this value controls the tick smoothing and bpm smoothing (currently both are disabled)
    ///   - bpmHistoryLimit:    When a bpm is calculated it's stored in a array which is sized by this number.
    ///                         The values in this array are averaged and that is the BPM result that is returned.
    ///                         If you make this number larger, then BPM will change very slowly.
    ///                         If you make this number small, then BPM will change very quickly.
    public init(smoothing: Float64 = 0.8, bpmHistoryLimit: Int = 3) {
        assert(bpmHistoryLimit > 0, "You must specify a positive number for bpmHistoryLimit")
        tickSmoothing = ValueSmoothing(factor: smoothing)
        bpmSmoothing = ValueSmoothing(factor: smoothing)
        bpmAveraging = BPMHistoryAveraging(countLimit: bpmHistoryLimit)

        super.init()

        clockListener = AKMIDIClockListener(srtListener: srtListener, tempoListener: self)

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
        clockListener = nil
    }
}

// MARK: - BPM Analysis

public extension AKMIDITempoListener {
    func analyze() {
        guard clockEvents.count > 1 else { return }
        guard clockEventLimit > 1 else { return }
        guard clockEvents.count >= clockEventLimit else { return }

        let previousClockTime = clockEvents[ clockEvents.count - 2 ]
        let currentClockTime = clockEvents[ clockEvents.count - 1 ]

        guard previousClockTime > 0 && currentClockTime > previousClockTime else { return }

        let clockDelta = currentClockTime - previousClockTime

        if timebaseInfo.denom == 0 {
            _ = mach_timebase_info(&timebaseInfo)
        }
        let numerator = Float64(clockDelta * UInt64(timebaseInfo.numer))
        let denominator = Float64(UInt64(oneThousand) * UInt64(timebaseInfo.denom))
        let intervalNanos = numerator / denominator

        //NSEC_PER_SEC
        let oneMillion = Float64(USEC_PER_SEC)
        let bpmCalc = ((oneMillion / intervalNanos / Float64(BEAT_TICKS)) * Float64(60.0)) + 0.055

        resetClockEventsLeavingOne()

        bpmStats.record(bpm: bpmCalc, time: currentClockTime)

        // bpmSmoothing.smoothed(
        let results = bpmStats.bpmFromRegressionAtTime(bpmStats.timeAt(ratio: 0.8)) // currentClockTime - 500000

        // Only report results when there is enough history to guess at the BPM
        let bpmToRecord: BPMType
        if results > 0 {
            bpmToRecord = BPMType(results)
        } else {
            bpmToRecord = BPMType(bpmCalc)
        }

        bpmAveraging.record(bpmToRecord)
        tempo = bpmAveraging.results.avg

        let newTempoString = String(format: "%3.2f", tempo)
        if newTempoString != tempoString {
            tempoString = newTempoString

            receivedTempo(bpm: bpmAveraging.results.avg, label: tempoString)
        }
    }

    func resetClockEventsLeavingOne() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count - 1).map { $0 }
    }

    func resetClockEventsLeavingHalf() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count / 2).map { $0 }
    }

    func resetClockEventsLeavingNone() {
        guard clockEvents.count > 1 else { return }
        clockEvents = []
    }
}

// MARK: - AKMIDITempoListener should be used as an AKMIDIListener

extension AKMIDITempoListener: AKMIDIListener {

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp) {
                if data[0] == AKMIDISystemCommand.clock.rawValue {
            clockTimeout?.succeed()
            clockTimeout?.perform {
                if self.incomingClockActive == false {
                    midiClockActivityStarted()
                    self.incomingClockActive = true
                }
                clockEvents.append(offset)
                analyze()
                clockListener?.midiClockBeat(time: offset)
            }
        }
        if data[0] == AKMIDISystemCommand.stop.rawValue {
            resetClockEventsLeavingNone()
        }
        if data[0] == AKMIDISystemCommand.start.rawValue {
            resetClockEventsLeavingOne()
        }
        srtListener.receivedMIDISystemCommand(data, portID: portID, offset: offset)
    }

    public func receivedMIDISetupChange() {
        // Do nothing
    }

    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }
}

// MARK: - Management and Communications for BPM Observers

extension AKMIDITempoListener {
    public func addObserver(_ observer: AKMIDITempoObserver) {
        tempoObservers.append(observer)
    }

    public func removeObserver(_ observer: AKMIDITempoObserver) {
        tempoObservers.removeAll { $0 == observer }
    }

    public func removeAllObserver() {
        tempoObservers.removeAll()
    }

    func midiClockActivityStarted() {
        tempoObservers.forEach { (observer) in
            observer.midiClockLeaderMode()
        }
    }

    func midiClockActivityStopped() {
        tempoObservers.forEach { (observer) in
            observer.midiClockLeaderEnabled()
        }
    }

    func receivedTempo(bpm: BPMType, label: String) {
        tempoObservers.forEach { (observer) in
            observer.receivedTempo(bpm: bpm, label: label)
        }
    }
}

#endif
