//
//  AKMIDIMMCListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// This AKMIDIListener looks for midi machine control (mmc)
/// midi system messages.
open class AKMIDIMMCListener : NSObject {
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
    var observers: [AKMIDIMMCObserver] = []
}

extension AKMIDIMMCListener : AKMIDIListener {
    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
        if data[0] == AKMIDISystemCommand.stop.rawValue {
            AKLog("Incoming MMC [Stop]")
            let newState = state.event(event: .stop)
            state = newState

            sendStopToObservers()
        }
        if data[0] == AKMIDISystemCommand.start.rawValue {
            AKLog("Incoming MMC [Start]")
            let newState = state.event(event: .start)
            state = newState

            sendStartToObservers()
        }
        if data[0] == AKMIDISystemCommand.continue.rawValue {
            AKLog("Incoming MMC [Continue]")
            let newState = state.event(event: .continue)
            state = newState

            sendContinueToObservers()
        }
    }
}

extension AKMIDIMMCListener {
    public func addObserver(_ observer: AKMIDIMMCObserver) {
        observers.append(observer)
    }

    public func removeObserver(_ observer: AKMIDIMMCObserver) {
        observers.removeAll { $0 == observer }
    }

    public func removeAllObserver(_ observer: AKMIDIMMCObserver) {
        observers.removeAll()
    }

    func sendStopToObservers() {
        observers.forEach { (observer) in
            observer.mmcStop(state: state)
        }
    }

    func sendStartToObservers() {
        observers.forEach { (observer) in
            observer.mmcStart(state: state)
        }
    }

    func sendContinueToObservers() {
        observers.forEach { (observer) in
            observer.mmcContinue(state: state)
        }
    }
}


