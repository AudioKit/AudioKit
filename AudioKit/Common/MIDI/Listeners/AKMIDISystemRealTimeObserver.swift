//
//  AKMIDISRTObserver.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public protocol AKMIDISystemRealTimeObserver {

    /// Called when a midi start system message is received
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func startSRT(listener: AKMIDISystemRealTimeListener)

    /// Called when a midi stop system message is received
    /// Stop should pause
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func stopSRT(listener: AKMIDISystemRealTimeListener)

    /// Called when a midi continue system message is received
    ///
    /// - Parameter srtListener: AKMIDISRTListener
    func continueSRT(listener: AKMIDISystemRealTimeListener)
}

// MARK: - Default handler methods for AKMIDIMMCEvents
extension AKMIDISystemRealTimeObserver {

    func startSRT(listener: AKMIDISystemRealTimeListener) {

    }

    func stopSRT(listener: AKMIDISystemRealTimeListener) {

    }

    func continueSRT(listener: AKMIDISystemRealTimeListener) {

    }

    public func isEqualTo(_ listener: AKMIDISystemRealTimeObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: AKMIDISystemRealTimeObserver, rhs: AKMIDISystemRealTimeObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}
