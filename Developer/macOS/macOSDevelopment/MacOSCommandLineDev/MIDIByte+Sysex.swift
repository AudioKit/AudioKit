//
//  MIDIByte+Sysex.swift
//  MacOSCommandLineDev
//
//  Created by Kurt Arnlund on 1/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

// MARK: - Extension related to the i/o message filter bits
extension MIDIByte {
    /// Internal function to convert a boolean to a 0x01 or 0x00 value
    ///
    /// - Parameter b: true(1) or false(0)
    /// - Returns: 1 or 0
    private static func boolToByte(_ b: Bool) -> Int8 {
        return (b ? 0x01 : 0x00)
    }

    /// Internal function to convert a single bit position to a boolean respresting whether the bit was 1(true) or 0(false)
    ///
    /// - Parameter pos: Bit position to test
    /// - Returns: true if bit position contains 1 or false if bit position contains 0
    private func bitToBool(_ pos: Int8) -> Bool {
        return (self & (1 << pos)) > 0
    }

    /// Constructor of a MIDIByte represting a bit field
    ///
    /// - Parameters:
    ///   - bit7:
    ///   - bit6:
    ///   - bit5:
    ///   - bit4:
    ///   - bit3:
    ///   - bit2:
    ///   - bit1:
    init(bit7: Bool, bit6: Bool, bit5: Bool, bit4: Bool, bit3: Bool, bit2: Bool, bit1: Bool) {
        let nibbleH = UInt8((bit7 ? 1 << 6 : 0) |
            (bit6 ? 1 << 5 : 0) |
            (bit5 ? 1 << 4 : 0))
        let nibbleL = UInt8((bit4 ? 1 << 3 : 0) |
            (bit3 ? 1 << 2 : 0) |
            (bit2 ? 1 << 1 : 0) |
            (bit1 ? 1 : 0))
        self = nibbleH | nibbleL
    }
}
