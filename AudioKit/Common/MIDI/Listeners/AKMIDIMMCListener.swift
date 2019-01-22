//
//  AKMIDIMMCListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

public protocol AKMIDIMMCEventsListener {

    /// Called when a clock slave mode is entered and this client is not allowed to become a clock master
    /// This signifies that there is an incoming midi clock detected
    func midiClockSlaveMode()

    /// Called when this client is allowed to become a clock master
    func midiClockMasterEnabled()

    /// Called when a midi start system message is received
    ///
    /// - Parameter state: current state
    func mmcStart(state: AKMIDIMMCListener.mmc_state)

    /// Called when a midi stop system message is received
    /// Stop should pause
    func mmcStop(state: AKMIDIMMCListener.mmc_state)

    /// Called when a midi continue system message is received
    //
    func mmcContinue(state: AKMIDIMMCListener.mmc_state)
}

// MARK: - Default handler methods for AKMIDIMMCEvents
extension AKMIDIMMCEventsListener {

    func midiClockSlaveMode() {

    }

    func midiClockMasterEnabled() {

    }

    func mmcStart(state: AKMIDIMMCListener.mmc_state) {

    }

    func mmcStop(state: AKMIDIMMCListener.mmc_state) {

    }

    func mmcContinue(state: AKMIDIMMCListener.mmc_state) {

    }

    func isEqualTo(_ listener : AKMIDIMMCEventsListener) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIMMCEventsListener, rhs: AKMIDIMMCEventsListener) -> Bool {
    return lhs.isEqualTo(rhs)
}

open class AKMIDIMMCListener: AKMIDIListener {
    enum mmc_event: MIDIByte {
        case stop = 0xFC
        case start = 0xFA
        case `continue` = 0xFB
    }

    public enum mmc_state {
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

    var listeners: [AKMIDIMMCEventsListener] = []

    public func addListener(_ listener: AKMIDIMMCEventsListener) {
        listeners.append(listener)
    }

    public func removeListener(_ listener: AKMIDIMMCEventsListener) {
        listeners.removeAll { $0 == listener }
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
        if data[0] == AKMIDISystemCommand.stop.rawValue {
            AKLog("Incoming MMC [Stop]")
            let newState = state.event(event: .stop)
            state = newState

            listeners.forEach { (listener) in
                listener.mmcStop(state: state)
            }
        }
        if data[0] == AKMIDISystemCommand.start.rawValue {
            AKLog("Incoming MMC [Start]")
            let newState = state.event(event: .start)
            state = newState

            listeners.forEach { (listener) in
                listener.mmcStart(state: state)
            }
        }
        if data[0] == AKMIDISystemCommand.continue.rawValue {
            AKLog("Incoming MMC [Continue]")
            let newState = state.event(event: .continue)
            state = newState

            listeners.forEach { (listener) in
                listener.mmcContinue(state: state)
            }
        }
    }

    func midiClockReceived() {
        listeners.forEach { (listener) in
            listener.midiClockSlaveMode()
        }
    }

    func midiClockStopped() {
        listeners.forEach { (listener) in
            listener.midiClockMasterEnabled()
        }
    }

}


