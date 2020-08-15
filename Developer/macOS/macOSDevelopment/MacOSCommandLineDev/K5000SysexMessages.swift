//
//  K5000SysexMessages.swift
//
//  Created by Kurt Arnlund on 1/12/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  A rather complete set of Kawai K5000 Sysex Message Definitions
//  Used as an example of how to setup Sysex Messages

import Foundation
import AudioKit

/// K5000 manufacturer and machine bytes
enum kawaiK5000: MIDIByte {
    case manufacturerId = 0x40
    case machine = 0x0A
}

/// K5000 sysex messages all have a midi channel byte
enum K5000sysexChannel: MIDIByte {
    case channel0 = 0x00
    case channel1 = 0x01
    case channel2 = 0x02
    case channel3 = 0x03
    case channel4 = 0x04
    case channel5 = 0x05
    case channel6 = 0x06
    case channel7 = 0x07
    case channel8 = 0x08
    case channel9 = 0x09
    case channel10 = 0x0A
    case channel11 = 0x0B
    case channel12 = 0x0C
    case channel13 = 0x0D
    case channel14 = 0x0E
    case channel15 = 0x0F
}

// MARK: - Usefull runs of sysex bytes
let kawaiK5000sysexStart: [MIDIByte] = [AKMIDISystemCommand.sysex.rawValue, kawaiK5000.manufacturerId.rawValue]

/// Request type words used across all devices
public enum K5000requestTypes: MIDIWord {
    case single = 0x0000
    case block = 0x0100
}

/// K5000SR requests
public enum K5000SRdumpRequests: MIDIWord {
    case areaA = 0x0000
    case areaC = 0x2000
    case areaD = 0x0002
}

/// K5000SR (with ME1 memory card installed) requests
public enum K5000ME1dumpRequests: MIDIWord {
    case areaE = 0x0003
    case areaF = 0x0004
}

/// K5000W requests
public enum K5000WdumpRequests: MIDIWord {
    case dump_reqest = 0x0000
    case areaBpcm = 0x0001
    case drumKit = 0x1000
    case drumInst = 0x1100
}

/// Sysex Message for the K5000S/R
class K5000messages {
    /// Block Single Dump Request (ADD A1-128)
    ///
    /// This request results in 77230 bytes of SYSEX - it take several seconds to get the full result
    ///
    /// - Parameter channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockSingleAreaA(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaA.rawValue.msb,
             K5000SRdumpRequests.areaA.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Single Dump Request (ADD A1-128)
    ///
    /// This request results in 1242 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - patch: (ADD A1-128) 0x00 - 0x7f
    /// - Returns: [MIDIByte]
    func oneSingleAreaA(channel: K5000sysexChannel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaA.rawValue.msb,
             K5000SRdumpRequests.areaA.rawValue.lsb,
             patch, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Block Combi Dump Request (Combi C1-64)
    ///
    /// This request results in 6600 bytes of SYSEX reponse
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockCombinationAreaC(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaC.rawValue.msb,
             K5000SRdumpRequests.areaC.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Combi Dump Request (Combi C1-64)
    ///
    /// This request results in 112 bytes of SYSEX reponse
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - combi: (Combi C1-64) 0x00 - 0x3f
    /// - Returns: [MIDIByte]
    func oneCombinationAreaC(channel: K5000sysexChannel, combi: UInt8) -> [MIDIByte] {
        guard combi <= 0x3f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaC.rawValue.msb,
             K5000SRdumpRequests.areaC.rawValue.lsb,
             combi, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Block Single Dump Request (ADD D1-128)
    ///
    /// This request results in 130428 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockSingleAreaD(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaD.rawValue.msb,
             K5000SRdumpRequests.areaD.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Single Dump Request (ADD D1-128)
    ///
    /// This request results in 1962 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - patch: (ADD D1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func oneSingleAreaD(channel: K5000sysexChannel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000SRdumpRequests.areaD.rawValue.msb,
             K5000SRdumpRequests.areaD.rawValue.lsb,
             patch, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Block Single Dump Request (ADD E1-128 - ME1 installed)
    ///
    /// This request results in 102340 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockSingleAreaE(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000ME1dumpRequests.areaE.rawValue.msb,
             K5000ME1dumpRequests.areaE.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Single Dump Request (ADD E1-128 - ME1 installed)
    ///
    /// This request results in 2768 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - patch: (ADD E1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func oneSingleAreaE(channel: K5000sysexChannel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000ME1dumpRequests.areaE.rawValue.msb,
             K5000ME1dumpRequests.areaE.rawValue.lsb,
             patch, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Block Single Dump Request (ADD F1-128 - ME1 installed)
    ///
    /// This request results in 110634 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockSingleAreaF(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000ME1dumpRequests.areaF.rawValue.msb,
             K5000ME1dumpRequests.areaF.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Single Dump Request (ADD F1-128 - ME1 installed)
    ///
    /// This request results in 1070 bytes of SYSEX response
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - patch: (ADD F1-128) 0x00 - 0x7F
    /// - Returns: [MIDIByte]
    func oneSingleAreaF(channel: K5000sysexChannel, patch: UInt8) -> [MIDIByte] {
        guard patch <= 0x7f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000ME1dumpRequests.areaF.rawValue.msb,
             K5000ME1dumpRequests.areaF.rawValue.lsb,
             patch, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }
}

/// Sysex Message for the K5000W
class K5000Wmessages {
    /// Block Single Dump Request PCM Area (B70-116)
    ///
    /// - Parameter channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockSingleAreaBpcm(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000WdumpRequests.areaBpcm.rawValue.msb,
             K5000WdumpRequests.areaBpcm.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Single Dumpe Request PCM Area (B70-116)
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - patch: patch number 0x45 - 0x73
    /// - Returns: [MIDIByte]
    func oneSingleAreaBpcm(channel: K5000sysexChannel, patch: UInt8) -> [MIDIByte] {
        guard patch >= 0x45 && patch <= 0x73 else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000WdumpRequests.areaBpcm.rawValue.msb,
             K5000WdumpRequests.areaBpcm.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Drum Kit Request (B117)
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func drumKit(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000WdumpRequests.drumKit.rawValue.msb,
             K5000WdumpRequests.drumKit.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// Block Drum Instrument Dump Request (Inst U1-32)
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    /// - Returns: [MIDIByte]
    func blockDrumInstrument(channel: K5000sysexChannel) -> [MIDIByte] {
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.block.rawValue.msb,
             K5000requestTypes.block.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000WdumpRequests.drumInst.rawValue.msb,
             K5000WdumpRequests.drumInst.rawValue.lsb,
             0x00, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }

    /// One Drum Instrument Dump Request (Inst U1-32)
    ///
    /// - Parameters:
    ///   - channel: K5000sysexChannel 0x00 - 0x0F
    ///   - instrument: instrument number 0x00 - 0x1F
    /// - Returns: [MIDIByte]
    func oneDrumInstrument(channel: K5000sysexChannel, instrument: UInt8) -> [MIDIByte] {
        guard instrument <= 0x1f else {
            return []
        }
        let request: [MIDIByte] = kawaiK5000sysexStart +
            [channel.rawValue,
             K5000requestTypes.single.rawValue.msb,
             K5000requestTypes.single.rawValue.lsb,
             kawaiK5000.machine.rawValue,
             K5000WdumpRequests.drumInst.rawValue.msb,
             K5000WdumpRequests.drumInst.rawValue.lsb,
             instrument, AKMIDISystemCommand.sysexEnd.rawValue]
        return request
    }
}
