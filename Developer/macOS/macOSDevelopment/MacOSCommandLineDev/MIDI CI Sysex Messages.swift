//
//  MIDI CI Sysex Messages.swift
//  MacOSCommandLineDev
//
//  Created by Kurt Arnlund on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

/// MIDI CI device id
enum MIDICIMessageTypeByte: MIDIByte {
    case universalSystemExclusive = 0x7E
}

/// MIDI CI device id
enum MIDICIDeviceId: MIDIByte {
    case toFromChannel0 = 0x00
    case toFromChannel1 = 0x01
    case toFromChannel2 = 0x02
    case toFromChannel3 = 0x03
    case toFromChannel4 = 0x04
    case toFromChannel5 = 0x05
    case toFromChannel6 = 0x06
    case toFromChannel7 = 0x07
    case toFromChannel8 = 0x08
    case toFromChannel9 = 0x09
    case toFromChannel10 = 0x0A
    case toFromChannel11 = 0x0B
    case toFromChannel12 = 0x0C
    case toFromChannel13 = 0x0D
    case toFromChannel14 = 0x0E
    case toFromChannel15 = 0x0F
    case toFromMidiPort  = 0x7F
}

enum MIDICISubID1: MIDIByte {
    case identifier = 0x0D
}

enum MIDICISubID2: MIDIByte {
    case reserved0 = 0x00
    case reserved1 = 0x01
    case reserved2 = 0x02
    case reserved3 = 0x03
    case reserved4 = 0x04
    case reserved5 = 0x05
    case reserved6 = 0x06
    case reserved7 = 0x07
    case reserved8 = 0x08
    case reserved9 = 0x09
    case reserved10 = 0x0A
    case reserved11 = 0x0B
    case reserved12 = 0x0C
    case reserved13 = 0x0D
    case reserved14 = 0x0E
    case reserved15 = 0x0F
    case protocolNegotiation0 = 0x10
    case protocolNegotiation1 = 0x11
    case protocolNegotiation2 = 0x12
    case protocolNegotiation3 = 0x13
    case protocolNegotiation4 = 0x14
    case protocolNegotiation5 = 0x15
    case protocolNegotiation6 = 0x16
    case protocolNegotiation7 = 0x17
    case protocolNegotiation8 = 0x18
    case protocolNegotiation9 = 0x19
    case protocolNegotiation10 = 0x1A
    case protocolNegotiation11 = 0x1B
    case protocolNegotiation12 = 0x1C
    case protocolNegotiation13 = 0x1D
    case protocolNegotiation14 = 0x1E
    case protocolNegotiation15 = 0x1F
    case profileConfiguration0 = 0x20
    case profileConfiguration1 = 0x21
    case profileConfiguration2 = 0x22
    case profileConfiguration3 = 0x23
    case profileConfiguration4 = 0x24
    case profileConfiguration5 = 0x25
    case profileConfiguration6 = 0x26
    case profileConfiguration7 = 0x27
    case profileConfiguration8 = 0x28
    case profileConfiguration9 = 0x29
    case profileConfiguration10 = 0x2A
    case profileConfiguration11 = 0x2B
    case profileConfiguration12 = 0x2C
    case profileConfiguration13 = 0x2D
    case profileConfiguration14 = 0x2E
    case profileConfiguration15 = 0x2F
    case propertyExchange0 = 0x30
    case propertyExchange1 = 0x31
    case propertyExchange2 = 0x32
    case propertyExchange3 = 0x33
    case propertyExchange4 = 0x34
    case propertyExchange5 = 0x35
    case propertyExchange6 = 0x36
    case propertyExchange7 = 0x37
    case propertyExchange8 = 0x38
    case propertyExchange9 = 0x39
    case propertyExchange10 = 0x3A
    case propertyExchange11 = 0x3B
    case propertyExchange12 = 0x3C
    case propertyExchange13 = 0x3D
    case propertyExchange14 = 0x3E
    case propertyExchange15 = 0x3F
    case reserved16 = 0x40
    case reserved17 = 0x41
    case reserved18 = 0x42
    case reserved19 = 0x43
    case reserved20 = 0x44
    case reserved21 = 0x45
    case reserved22 = 0x46
    case reserved23 = 0x47
    case reserved24 = 0x48
    case reserved25 = 0x49
    case reserved26 = 0x4A
    case reserved27 = 0x4B
    case reserved28 = 0x4C
    case reserved29 = 0x4D
    case reserved30 = 0x4E
    case reserved31 = 0x4F
    case reserved32 = 0x50
    case reserved33 = 0x51
    case reserved34 = 0x52
    case reserved35 = 0x53
    case reserved36 = 0x54
    case reserved37 = 0x55
    case reserved38 = 0x56
    case reserved39 = 0x57
    case reserved40 = 0x58
    case reserved41 = 0x59
    case reserved42 = 0x5A
    case reserved43 = 0x5B
    case reserved44 = 0x5C
    case reserved45 = 0x5D
    case reserved46 = 0x5E
    case reserved47 = 0x5F
    case reserved48 = 0x60
    case reserved49 = 0x61
    case reserved50 = 0x62
    case reserved51 = 0x63
    case reserved52 = 0x64
    case reserved53 = 0x65
    case reserved54 = 0x66
    case reserved55 = 0x67
    case reserved56 = 0x68
    case reserved57 = 0x69
    case reserved58 = 0x6A
    case reserved59 = 0x6B
    case reserved60 = 0x6C
    case reserved61 = 0x6D
    case reserved62 = 0x6E
    case reserved63 = 0x6F
    case reserved64 = 0x70
    case reserved65 = 0x71
    case reserved66 = 0x72
    case reserved67 = 0x73
    case reserved68 = 0x74
    case reserved69 = 0x75
    case reserved70 = 0x76
    case reserved71 = 0x77
    case reserved72 = 0x78
    case reserved73 = 0x79
    case reserved74 = 0x7A
    case reserved75 = 0x7B
    case reserved76 = 0x7C
    case reserved77 = 0x7D
    case reserved78 = 0x7E
    case NAK = 0x7F
}

enum MIDICIVersion: MIDIByte {
    case v1 = 0x00
}

let MIDICISysexStart: [MIDIByte] = [AKMIDISystemCommand.sysex.rawValue,
                                    MIDICIMessageTypeByte.universalSystemExclusive.rawValue]

struct MNID {
    var mnid_high: MIDIWord = 0
    var mnid_low: MIDIWord = 0

    init() {
        topologyChanged()
    }

    mutating func topologyChanged() {
        let random32 = UInt32.random(in: 0...(2 ^ 28))
        mnid_high = MIDIWord(UInt16(random32 >> 16))
        mnid_low = MIDIWord(UInt16(random32 & 0x0000FFFF))
    }
}

class MIDICIMessage {
    let mnid = MNID()
    let bytes: [MIDIByte]

    /// Init a Midi CI message
    ///
    /// - Parameters:
    ///   - deviceId: to/from port or channel
    ///   - subID2: Sub ID #2
    ///   - data: message data contents
    ///
    /// for some products, data contains more sysex
    init(deviceId: MIDICIDeviceId, subId2: MIDICISubID2, data: [MIDIByte] = []) {
        if data.count > 0 {
            bytes = MIDICISysexStart +
                [deviceId.rawValue,
                 MIDICISubID1.identifier.rawValue,
                 subId2.rawValue,
                 MIDICIVersion.v1.rawValue,
                 mnid.mnid_high.msb,
                 mnid.mnid_high.lsb,
                 mnid.mnid_low.msb,
                 mnid.mnid_low.lsb] +
                 data + [AKMIDISystemCommand.sysexEnd.rawValue]
        } else {
            bytes = MIDICISysexStart +
                [deviceId.rawValue,
                 MIDICISubID1.identifier.rawValue,
                 subId2.rawValue,
                 MIDICIVersion.v1.rawValue,
                 mnid.mnid_high.msb,
                 mnid.mnid_high.lsb,
                 mnid.mnid_low.msb,
                 mnid.mnid_low.lsb,
                 AKMIDISystemCommand.sysexEnd.rawValue]
        }
    }

    /// Init a NAK message
    ///
    /// - Parameter deviceId: to/from port or channel
    convenience init(deviceId: MIDICIDeviceId) {
        self.init(deviceId: deviceId, subId2: .NAK)
    }
}
