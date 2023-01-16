// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Protocol that must be adhered to if you want your class to respond to MIDI
///
/// Implement the MIDIListener protocol on any classes that need to respond
/// to incoming MIDI events.
///

#if !os(tvOS)

import os.log
import AVFoundation
import Utilities
import MIDIKitIO

let MIDIListenerLogging = false

/// MIDI Listener protocol
public protocol MIDIListener {
    /// Received a MIDI event
    func received(midiEvent: MIDIEvent, timeStamp: CoreMIDITimeStamp, source: MIDIOutputEndpoint?)

    /// Generic MIDI System Notification
    func received(midiNotification: MIDIIONotification)
}

/// Default listener functions
public extension MIDIListener {
    /// Equality test
    /// - Parameter listener: Another listener
    func isEqualTo(_ listener: MIDIListener) -> Bool {
        return self == listener
    }
}

func == (lhs: MIDIListener, rhs: MIDIListener) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
