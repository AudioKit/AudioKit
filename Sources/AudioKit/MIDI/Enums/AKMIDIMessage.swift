// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// A basic container for a MIDI message, so that they can be used in different contexts
// by accessing .data: [UInt8] directly

public protocol AKMIDIMessage {
    var data: [UInt8] { get }
    var description: String { get }
}
