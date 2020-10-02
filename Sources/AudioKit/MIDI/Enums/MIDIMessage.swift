// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// A basic container for a MIDI message, so that they can be used in different contexts
// by accessing .data: [MIDIByte] directly

/// MIDI Message Protocol
public protocol MIDIMessage {
    /// Array of MIDI Bytes
    var data: [MIDIByte] { get }
    /// Pretty printout
    var description: String { get }
}
