//
//  AKMIDISRTObserver.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public protocol AKMIDISRTObserver {

    /// Called when a midi start system message is received
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func SRTStart(srtListener: AKMIDISRTListener)

    /// Called when a midi stop system message is received
    /// Stop should pause
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func SRTStop(srtListener: AKMIDISRTListener)

    /// Called when a midi continue system message is received
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func SRTContinue(srtListener: AKMIDISRTListener)
}

// MARK: - Default handler methods for AKMIDIMMCEvents
extension AKMIDISRTObserver {

    func SRTStart(srtListener: AKMIDISRTListener) {

    }

    func SRTStop(srtListener: AKMIDISRTListener) {

    }

    func SRTContinue(srtListener: AKMIDISRTListener) {

    }

    public func isEqualTo(_ listener : AKMIDISRTObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDISRTObserver, rhs: AKMIDISRTObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}
