// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation
import CoreMIDI
import os.log
import Utilities

/// This MIDIListener looks for midi system real time (SRT)
/// midi system messages.
open class MIDISystemRealTimeListener: NSObject {
    enum SRTEvent: Equatable, Hashable {
        case stop
        case start
        case `continue`
    }

    /// System real-time state
    public enum SRTState {
        /// Stopped
        case stopped
        /// Playing
        case playing
        /// Paused
        case paused

        func event(event: SRTEvent) -> SRTState {
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

    var state: SRTState = .stopped
    var observers: [MIDISystemRealTimeObserver] = []
}

extension MIDISystemRealTimeListener: MIDIListener {
    public func received(midiEvent: MIDIEvent, timeStamp: CoreMIDITimeStamp, source: MIDIOutputEndpoint?) {
        switch midiEvent {
        case .start(_):
            Log("Incoming MMC [Start]", log: OSLog.midi)
            let newState = state.event(event: .start)
            state = newState
            
            sendStartToObservers()
            
        case .stop(_):
            Log("Incoming MMC [Stop]", log: OSLog.midi)
            let newState = state.event(event: .stop)
            state = newState
            
            sendStopToObservers()
            
        case .continue(_):
            Log("Incoming MMC [Continue]", log: OSLog.midi)
            let newState = state.event(event: .continue)
            state = newState
            
            sendContinueToObservers()
            
        default:
            break
        }
    }
    
    public func received(midiNotification: MIDIKitIO.MIDIIONotification) {
        // not used
    }
}

extension MIDISystemRealTimeListener {
    /// Add MIDI System real-time observer
    /// - Parameter observer: MIDI System real-time observer
    public func addObserver(_ observer: MIDISystemRealTimeObserver) {
        observers.append(observer)
    }

    /// Remove MIDI System real-time observer
    /// - Parameter observer: MIDI System real-time observer
    public func removeObserver(_ observer: MIDISystemRealTimeObserver) {
        observers.removeAll { $0 == observer }
    }

    /// Remove all observers
    public func removeAllObservers() {
        observers.removeAll()
    }
    /// Send stop command to all observers
    func sendStopToObservers() {
        for observer in observers { observer.stopSRT(listener: self) }
    }

    func sendStartToObservers() {
        for observer in observers { observer.startSRT(listener: self) }
    }

    func sendContinueToObservers() {
        for observer in observers { observer.continueSRT(listener: self) }
    }
}

#endif
