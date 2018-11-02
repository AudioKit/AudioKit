//
//  AKMIDIMetaEventType.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public enum AKMIDIMetaEventType : MIDIByte {
    case sequenceNumber = 0x00
    case textEvent = 0x01
    case copyright = 0x02
    case trackName = 0x03
    case instrumentName = 0x04
    case lyric = 0x05
    case marker = 0x06
    case cuePoint = 0x07
    case channelPrefix = 0x20
    case endOfTrack = 0x2F
    case setTempo = 0x51
    case smtpeOffset = 0x54
    case timeSignature = 0x58
    case keySignature = 0x59
    case sequencerSpecificMetaEvent = 0x7F

    static func with(type: UInt8) -> AKMIDIMetaEventType? {
        return AKMIDIMetaEventType(rawValue: type)
    }

    var description: String {
        switch self {
        case .sequenceNumber:
            return "Sequence Number"
        case .textEvent:
            return "Text Event"
        case .copyright:
            return "Copyright"
        case .trackName:
            return "Track Name"
        case .instrumentName:
            return "Instrument Name"
        case .lyric:
            return "Lyric"
        case .marker:
            return "Marker"
        case .cuePoint:
            return "Cue Point"
        case .channelPrefix:
            return "Channel Prefix"
        case .endOfTrack:
            return "End of Track"
        case .setTempo:
            return "Set Tempo"
        case .smtpeOffset:
            return "SMPTE Offset"
        case .timeSignature:
            return "Time Signature"
        case .keySignature:
            return "Key Signature"
        case .sequencerSpecificMetaEvent:
            return "Sequence Specific"
        }
    }
}
