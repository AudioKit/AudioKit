//
//  K5000SysexMessages.swift
//
//  Created by Kurt Arnlund on 1/12/19.
//  Copyright © 2019 iatapps. All rights reserved.
//

import Foundation
import AudioKit

/// K5000 manufacturer and machine bytes
enum kawai_K5000 : MIDIByte {
    case manufacturer_id = 0x40
    case machine         = 0x0A
}

/// K5000 sysex messages all have a midi channel byte
enum K5000_sysex_channel : MIDIByte {
    case channel_0 = 0x00
    case channel_1 = 0x01
    case channel_2 = 0x02
    case channel_3 = 0x03
    case channel_4 = 0x04
    case channel_5 = 0x05
    case channel_6 = 0x06
    case channel_7 = 0x07
    case channel_8 = 0x08
    case channel_9 = 0x09
    case channel_10 = 0x0A
    case channel_11 = 0x0B
    case channel_12 = 0x0C
    case channel_13 = 0x0D
    case channel_14 = 0x0E
    case channel_15 = 0x0F
}

// MARK: - Usefull runs of sysex bytes
let K5000_SYSEX_START : [MIDIByte] = [AKMIDISystemCommand.sysex.rawValue, kawai_K5000.manufacturer_id.rawValue]
let SYSEX_END : [MIDIByte] = [AKMIDISystemCommand.sysexEnd.rawValue]

/// Request type words used across all devices
public enum K5000_RequestTypes: MIDIWord {
    case single         = 0x0000
    case block          = 0x0100
}

/// K5000SR requests
public enum K5000SR_Requests: MIDIWord {
    case area_a_dump_reqest     = 0x0000
    case area_c_dump_reqest     = 0x2000
    case area_d_dump_reqest     = 0x0002
}

/// K5000SR (with ME1 memory card installed) requests
public enum K5000_ME1_Requests: MIDIWord {
    case area_e_dump_reqest     = 0x0003
    case area_f_dump_reqest     = 0x0004
}

/// K5000W requests
public enum K5000W_Requests: MIDIWord {
    case dump_reqest                = 0x0000
    case area_b_dump_request_pcm    = 0x0001
    case dump_request_drum_kit      = 0x1000
    case dump_request_drum_inst     = 0x1100
}

// MARK: - Extensions to MIDIWord
extension MIDIWord {
    /// Create a MIDIWord for a command and command version
    ///
    /// - Parameters:
    ///   - command: Command Byte Value
    ///   - version: Command Byte Version Value
    init(command:MIDIByte, version: MIDIByte) {
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

// MARK: - Extension related to the i/o message filter bits
extension MIDIByte {
    /// Internal function to convert a boolean to a 0x01 or 0x00 value
    ///
    /// - Parameter b: true(1) or false(0)
    /// - Returns: 1 or 0
    private static func boolToByte(_ b:Bool) -> Int8 {
        return (b ? 0x01 : 0x00)
    }

    /// Internal function to convert a single bit position to a boolean respresting whether the bit was 1(true) or 0(false)
    ///
    /// - Parameter pos: Bit position to test
    /// - Returns: true if bit position contains 1 or false if bit position contains 0
    private func bitToBool(_ pos:Int8) -> Bool {
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
    init(bit7:Bool, bit6:Bool, bit5:Bool, bit4:Bool, bit3:Bool, bit2:Bool, bit1:Bool)  {
        let nibbleH = UInt8((bit7 ? 1<<6 : 0) |
            (bit6 ? 1<<5 : 0) |
            (bit5 ? 1<<4 : 0))
        let nibbleL = UInt8((bit4 ? 1<<3 : 0) |
            (bit3 ? 1<<2 : 0) |
            (bit2 ? 1<<1 : 0) |
            (bit1 ? 1 : 0))
        self = nibbleH | nibbleL

    }
}

/// Sysex Message for the K5000S/R
class K5000_messages {
    /// Block Single Dump Request (ADD A1-128)
    ///
    /// This request results in 77230 bytes of SYSEX - it take several seconds to get the full result
    ///
    /// - Parameter channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_single_ADD_A(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_a_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_a_dump_reqest.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Single Dump Request (ADD A1-128)
    ///
    /// This request results in 1242 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - patch: (ADD A1-128) 0x00 - 0x7f
    /// - Returns: [MIDIByte]
    func one_single_ADD_A(channel: K5000_sysex_channel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_a_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_a_dump_reqest.rawValue.lsb,
             patch] + SYSEX_END
        return request
    }

    /// Block Combi Dump Request (Combi C1-64)
    ///
    /// This request results in 6600 bytes of SYSEX reponse
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_combination_C(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_c_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_c_dump_reqest.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Combi Dump Request (Combi C1-64)
    ///
    /// This request results in 112 bytes of SYSEX reponse
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - combi: (Combi C1-64) 0x00 - 0x3f
    /// - Returns: [MIDIByte]
    func one_combination_C(channel: K5000_sysex_channel, combi: UInt8) -> [MIDIByte] {
        guard combi <= 0x3f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_c_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_c_dump_reqest.rawValue.lsb,
             combi] + SYSEX_END
        return request
    }

    /// Block Single Dump Request (ADD D1-128)
    ///
    /// This request results in 130428 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_single_ADD_D(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_d_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_d_dump_reqest.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Single Dump Request (ADD D1-128)
    ///
    /// This request results in 1962 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - patch: (ADD D1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func one_single_ADD_D(channel: K5000_sysex_channel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000SR_Requests.area_d_dump_reqest.rawValue.msb,
             K5000SR_Requests.area_d_dump_reqest.rawValue.lsb,
             patch] + SYSEX_END
        return request
    }

    /// Block Single Dump Request (ADD E1-128 - ME1 installed)
    ///
    /// This request results in 102340 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_single_ADD_E(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000_ME1_Requests.area_e_dump_reqest.rawValue.msb,
             K5000_ME1_Requests.area_e_dump_reqest.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Single Dump Request (ADD E1-128 - ME1 installed)
    ///
    /// This request results in 2768 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - patch: (ADD E1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func one_single_ADD_E(channel: K5000_sysex_channel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000_ME1_Requests.area_e_dump_reqest.rawValue.msb,
             K5000_ME1_Requests.area_e_dump_reqest.rawValue.lsb,
             patch] + SYSEX_END
        return request
    }

    /// Block Single Dump Request (ADD F1-128 - ME1 installed)
    ///
    /// This request results in 110634 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_single_ADD_F(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000_ME1_Requests.area_f_dump_reqest.rawValue.msb,
             K5000_ME1_Requests.area_f_dump_reqest.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Single Dump Request (ADD F1-128 - ME1 installed)
    ///
    /// This request results in 1070 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - patch: (ADD F1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func one_single_ADD_F(channel: K5000_sysex_channel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000_ME1_Requests.area_f_dump_reqest.rawValue.msb,
             K5000_ME1_Requests.area_f_dump_reqest.rawValue.lsb,
             patch] + SYSEX_END
        return request
    }
}

/// Sysex Message for the K5000W
class K5000W_messages {
    /// Block Single Dump Request PCM Area (B70-116)
    ///
    /// - Parameter channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_single_PCM(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000W_Requests.area_b_dump_request_pcm.rawValue.msb,
             K5000W_Requests.area_b_dump_request_pcm.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Single Dumpe Request PCM Area (B70-116)
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - patch: patch number 0x45 - 0x73
    /// - Returns: [MIDIByte]
    func one_single_PCM(channel: K5000_sysex_channel, patch: UInt8) -> [MIDIByte] {
        guard patch >= 0x45 && patch <= 0x73 else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000W_Requests.area_b_dump_request_pcm.rawValue.msb,
             K5000W_Requests.area_b_dump_request_pcm.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// Drum Kit Request (B117)
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func drum_kit(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000W_Requests.dump_request_drum_kit.rawValue.msb,
             K5000W_Requests.dump_request_drum_kit.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// Block Drum Instrument Dump Request (Inst U1-32)
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func block_drum_instrument(channel: K5000_sysex_channel) -> [MIDIByte] {
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.block.rawValue.msb,
             K5000_RequestTypes.block.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000W_Requests.dump_request_drum_inst.rawValue.msb,
             K5000W_Requests.dump_request_drum_inst.rawValue.lsb,
             0x00] + SYSEX_END
        return request
    }

    /// One Drum Instrument Dump Request (Inst U1-32)
    ///
    /// - Parameters:
    ///   - channel: K5000_sysex_channel 0x00 - 0x0F
    ///   - instrument: instrument number 0x00 - 0x1F
    /// - Returns: [MIDIByte]
    func one_drum_instrument(channel: K5000_sysex_channel, instrument: UInt8) -> [MIDIByte] {
        guard instrument <= 0x1f else {
            return []
        }
        let request : [MIDIByte] = K5000_SYSEX_START +
            [channel.rawValue,
             K5000_RequestTypes.single.rawValue.msb,
             K5000_RequestTypes.single.rawValue.lsb,
             kawai_K5000.machine.rawValue,
             K5000W_Requests.dump_request_drum_inst.rawValue.msb,
             K5000W_Requests.dump_request_drum_inst.rawValue.lsb,
             instrument] + SYSEX_END
        return request
    }
}
