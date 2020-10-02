// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation

/// MIDI System Real Time Observer
public protocol MIDISystemRealTimeObserver {

    /// Called when a midi start system message is received
    ///
    /// - Parameter srtListener: MIDISRTListener
    func startSRT(listener: MIDISystemRealTimeListener)

    /// Called when a midi stop system message is received
    /// Stop should pause
    ///
    /// - Parameter srtListener: MIDISRTListener
    func stopSRT(listener: MIDISystemRealTimeListener)

    /// Called when a midi continue system message is received
    ///
    /// - Parameter srtListener: MIDISRTListener
    func continueSRT(listener: MIDISystemRealTimeListener)
}

/// Default handler methods for MIDI MMC Events
extension MIDISystemRealTimeObserver {

    func startSRT(listener: MIDISystemRealTimeListener) {

    }

    func stopSRT(listener: MIDISystemRealTimeListener) {

    }

    func continueSRT(listener: MIDISystemRealTimeListener) {

    }

    /// Equality check
    /// - Parameter listener: MIDI System Real-Time Observer
    /// - Returns: Equality boolean
    public func isEqualTo(_ listener: MIDISystemRealTimeObserver) -> Bool {
        return self == listener
    }
}

func == (lhs: MIDISystemRealTimeObserver, rhs: MIDISystemRealTimeObserver) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
