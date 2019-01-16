//
//  MIDIWord+Sysex.swift
//  MacOSCommandLineDev
//
//  Created by Kurt Arnlund on 1/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

// MARK: - Extensions to MIDIWord
extension MIDIWord {
    /// Create a MIDIWord for a command and command version
    ///
    /// - Parameters:
    ///   - command: Command Byte Value
    ///   - version: Command Byte Version Value
    init(command: MIDIByte, version: MIDIByte) {
        self = MIDIWord((command << 8) | version)
    }

    /// Create a MIDIWord from a byte by taking the
    /// upper nibble and lower nibble of a byte,
    /// and separating each into a byte in the word
    ///
    /// - Parameter ioBitmap: Full 8bits of ioMapping for one output
    init(ioBitmap: UInt8) {
        let high = (ioBitmap & 0xF0) >> 4
        let low = ioBitmap & 0x0F
        self = UInt16(high << 8) | UInt16(low)
    }

    /// Most significant byte in a MIDIWord
    var msb: MIDIByte {
        return MIDIByte(self >> 8)
    }

    /// Lease significant byte in a MIDIWord
    var lsb: MIDIByte {
        return MIDIByte(self & 0x00FF)
    }
}
