//
//  AKMIDIMMCObserver.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public protocol AKMIDIMMCObserver {

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
extension AKMIDIMMCObserver {

    func mmcStart(state: AKMIDIMMCListener.mmc_state) {

    }

    func mmcStop(state: AKMIDIMMCListener.mmc_state) {

    }

    func mmcContinue(state: AKMIDIMMCListener.mmc_state) {

    }

    public func isEqualTo(_ listener : AKMIDIMMCObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDIMMCObserver, rhs: AKMIDIMMCObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}
