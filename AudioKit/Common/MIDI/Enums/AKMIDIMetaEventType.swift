// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public enum AKMIDIMetaEventType: MIDIByte {
    case sequenceNumber = 0x00
    case textEvent = 0x01
    case copyright = 0x02
    case trackName = 0x03
    case instrumentName = 0x04
    case lyric = 0x05
    case marker = 0x06
    case cuePoint = 0x07
    case programName = 0x08
    case devicePortName = 0x09
    case metaEvent10 = 0x0A
    case metaEvent12 = 0x0C
    case channelPrefix = 0x20
    case midiPort = 0x21
    case endOfTrack = 0x2F
    case setTempo = 0x51
    case smtpeOffset = 0x54
    case timeSignature = 0x58
    case keySignature = 0x59
    case sequencerSpecificMetaEvent = 0x7F

    var length: Int? { //length can be variable for certain metaevents, so returns nil for the type length
        switch self {
        case .endOfTrack:
            return 0
        case .channelPrefix, .midiPort:
            return 1
        case .keySignature, .sequenceNumber:
            return 2
        case .setTempo:
            return 3
        case .timeSignature:
            return 4
        case .smtpeOffset:
            return 5
        default:
            return nil
        }
    }

    public var description: String {
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
        case .programName:
            return "Program Name"
        case .devicePortName:
            return "Device (Port) Name"
        case .metaEvent10:
            return "Meta Event 10"
        case .metaEvent12:
            return "Meta Event 12"
        case .channelPrefix:
            return "Channel Prefix"
        case .midiPort:
            return "MIDI Port"
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

public struct AKMIDIMetaEvent: AKMIDIMessage {

    /// Position data - used for events parsed from a MIDI file
    public var positionInBeats: Double?

    public init?(data: [MIDIByte]) {
        if data.count > 2,
            data[0] == 0xFF,
            let type = AKMIDIMetaEventType(rawValue: data[1]),
            let vlqLength = MIDIVariableLengthQuantity(fromBytes: Array(data.suffix(from: 2))) {
            self.length = Int(vlqLength.quantity)
            self.data = Array(data.prefix(3 + length)) //drop excess data
            self.type = type
        } else {
            return nil
        }
    }

    init?(fileEvent event: AKMIDIFileChunkEvent) {
        guard
            let metaEvent = AKMIDIMetaEvent(data: event.computedData)
        else {
            return nil
        }
        self = metaEvent
        if event.timeFormat == .ticksPerBeat {
            positionInBeats = event.position
        }
    }

    public let data: [MIDIByte]
    public let type: AKMIDIMetaEventType
    public let length: Int
    public var description: String {
        var nameStr: String = ""

        if let name = name, (
            type == .trackName ||
            type == .instrumentName ||
            type == .programName ||
            type == .devicePortName ||
            type == .metaEvent10 ||
            type == .metaEvent12) {
            nameStr = "- \(name)"
        }

        return type.description + " \(length) bytes long \(nameStr)"
    }

    public var name: String? {
        return String(bytes: data.suffix(length), encoding: .utf8)
    }

}
