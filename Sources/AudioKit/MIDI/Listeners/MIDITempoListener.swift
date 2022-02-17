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

/// Type to store tempo in BeatsPerMinute
public typealias BPMType = TimeInterval

/// A AudioKit midi listener that looks at midi clock messages and calculates a BPM
///
/// Usage:
///
///     let tempoListener = MIDITempoListener()
///     MIDI().addListener(tempoListener)
///
/// Make your class a MIDITempoObserver and you will receive callbacks when the BPM
/// changes.
///
///     class YOURCLASS: MIDITempoObserver {
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
public class MIDITempoListener: NSObject {

    /// Clock listener
    public var clockListener: MIDIClockListener?

    /// System Real-time Listener
    public var srtListener = MIDISystemRealTimeListener()

    var tempoObservers: [MIDITempoObserver] = []

    /// Tempo string
    public var tempoString: String = ""

    /// Tempo in "BPM Type"
    public var tempo: BPMType = 0
    var clockEvents: [UInt64] = []
    let clockEventLimit = 2
    var bpmStats = BPMHistoryStatistics()
    var bpmAveraging: BPMHistoryAveraging
    var timebaseInfo = mach_timebase_info()
    var tickSmoothing: ValueSmoothing
    var bpmSmoothing: ValueSmoothing

    var clockTimeout: MIDITimeout?

    /// Is the Incoming Clock active?
    public var isIncomingClockActive = false

    let BEAT_TICKS = 24
    let oneThousand = UInt64(1_000)

    /// Create a BPM Listener
    ///
    /// This object creates a clockListener: MIDIClockListener
    /// The MIDIClockListener is informed every time there is a clock and it in turn informs its
    /// MIDIBeatObserver's whenever beat events happen.
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

        clockListener = MIDIClockListener(srtListener: srtListener, tempoListener: self)

        if timebaseInfo.denom == 0 {
            _ = mach_timebase_info(&timebaseInfo)
        }

        clockTimeout = MIDITimeout(timeoutInterval: 1.6, onMainThread: true, success: {}, timeout: {
            if self.isIncomingClockActive == true {
                self.midiClockActivityStopped()
            }
            self.isIncomingClockActive = false
        })
        midiClockActivityStopped()
    }

    deinit {
        clockTimeout = nil
        clockListener = nil
    }
}

// MARK: - BPM Analysis

public extension MIDITempoListener {
    /// Analyze tempo
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

    /// Reset all clock events except the last one
    func resetClockEventsLeavingOne() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count - 1).map { $0 }
    }

    /// Reset all clock events leaving half remaining
    func resetClockEventsLeavingHalf() {
        guard clockEvents.count > 1 else { return }
        clockEvents = clockEvents.dropFirst(clockEvents.count / 2).map { $0 }
    }

    /// Reset all clock events leaving none
    func resetClockEventsLeavingNone() {
        guard clockEvents.count > 1 else { return }
        clockEvents = []
    }
}

// MARK: - MIDITempoListener should be used as an MIDIListener

extension MIDITempoListener: MIDIListener {
    /// Receive a MIDI system command (such as clock, SysEx, etc)
    ///
    /// - data:       Array of integers
    /// - portID:     MIDI Unique Port ID
    /// - offset:     MIDI Event TimeStamp
    ///
    public func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID? = nil, timeStamp: MIDITimeStamp? = nil) {
        if data[0] == MIDISystemCommand.clock.rawValue {
            clockTimeout?.succeed()
            clockTimeout?.perform {
                if self.isIncomingClockActive == false {
                    midiClockActivityStarted()
                    self.isIncomingClockActive = true
                }
                let timeStamp = timeStamp ?? 0
                clockEvents.append(timeStamp)
                analyze()
                clockListener?.midiClockBeat(timeStamp: timeStamp)
            }
        }
        if data[0] == MIDISystemCommand.stop.rawValue {
            resetClockEventsLeavingNone()
        }
        if data[0] == MIDISystemCommand.start.rawValue {
            resetClockEventsLeavingOne()
        }
        srtListener.receivedMIDISystemCommand(data, portID: portID, timeStamp: timeStamp)
    }
    
    /// Receive the MIDI note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of activated note
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive the MIDI note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number of released note
    ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                    velocity: MIDIVelocity,
                                    channel: MIDIChannel,
                                    portID: MIDIUniqueID? = nil,
                                    timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte, channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///   - portID:     MIDI Unique Port ID
    ///   - timeStamp:  MIDI Event TimeStamp
    ///
    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                       pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - timeStamp:MIDI Event TimeStamp
    ///
    public func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///   - portID:          MIDI Unique Port ID
    ///   - timeStamp:       MIDI Event TimeStamp
    ///
    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                       channel: MIDIChannel,
                                       portID: MIDIUniqueID? = nil,
                                       timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// Receive program change
    ///
    /// - Parameters:
    ///   - program:  MIDI Program Value (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///   - portID:   MIDI Unique Port ID
    ///   - timeStamp:MIDI Event TimeStamp
    ///
    public func receivedMIDIProgramChange(_ program: MIDIByte,
                                          channel: MIDIChannel,
                                          portID: MIDIUniqueID? = nil,
                                          timeStamp: MIDITimeStamp? = nil) {
        // Do nothing
    }

    /// MIDI Setup has changed
    public func receivedMIDISetupChange() {
        // Do nothing
    }

    /// MIDI Object Property has changed
    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    /// Generic MIDI Notification
    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }

}

// MARK: - Management and Communications for BPM Observers

extension MIDITempoListener {

    /// Add a MIDI Tempo Observer
    /// - Parameter observer: Tempo observer to add
    public func addObserver(_ observer: MIDITempoObserver) {
        tempoObservers.append(observer)
    }

    /// Remove a tempo observer
    /// - Parameter observer: Tempo observer to remove
    public func removeObserver(_ observer: MIDITempoObserver) {
        tempoObservers.removeAll { $0 == observer }
    }

    /// Remove all tempo observers
    public func removeAllObservers() {
        tempoObservers.removeAll()
    }

    func midiClockActivityStarted() {
        for observer in tempoObservers { observer.midiClockLeaderMode() }
    }

    func midiClockActivityStopped() {
        for observer in tempoObservers { observer.midiClockLeaderEnabled() }
    }

    func receivedTempo(bpm: BPMType, label: String) {
        for observer in tempoObservers { observer.receivedTempo(bpm: bpm, label: label) }
    }
}

#endif
