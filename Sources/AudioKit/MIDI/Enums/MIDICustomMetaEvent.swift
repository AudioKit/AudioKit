// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// MIDI Custom Meta Event Type
public enum MIDICustomMetaEventType: MIDIByte {
    /// Sequence Number
    case sequenceNumber = 0x00
    /// Text Event
    case textEvent = 0x01
    /// Copyright
    case copyright = 0x02
    /// Track Name
    case trackName = 0x03
    /// Instrument Name
    case instrumentName = 0x04
    /// Lyric
    case lyric = 0x05
    /// Marker
    case marker = 0x06
    /// Cue Point
    case cuePoint = 0x07
    /// Program Name
    case programName = 0x08
    /// Device Port Name
    case devicePortName = 0x09
    /// Meta Event 10
    case metaEvent10 = 0x0A
    /// Meta Event 12
    case metaEvent12 = 0x0C
    /// Channel Prefix
    case channelPrefix = 0x20
    /// MIDI Port
    case midiPort = 0x21
    /// End of Track
    case endOfTrack = 0x2F
    /// Set Tempo
    case setTempo = 0x51
    /// SMTPE Offset
    case smtpeOffset = 0x54
    /// Time Signature
    case timeSignature = 0x58
    /// Key Signature
    case keySignature = 0x59
    /// Sequencer Specific Meta Event
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

    /// Custom event pretty name
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

/// MIDI Custom Meta Event
public struct MIDICustomMetaEvent: MIDIMessage {

    /// Position data - used for events parsed from a MIDI file
    public var positionInBeats: Double?

    /// Initialize with data
    /// - Parameter data: Array of MIDI bytes
    public init?(data: [MIDIByte]) {
        if data.count > 2,
            data[0] == 0xFF,
            let type = MIDICustomMetaEventType(rawValue: data[1]),
            let vlqLength = MIDIVariableLengthQuantity(fromBytes: Array(data.suffix(from: 2))) {
            self.length = Int(vlqLength.quantity)
            self.data = Array(data.prefix(3 + length)) //drop excess data
            self.type = type
        } else {
            return nil
        }
    }

    /// Initialize ith MIDI File Chunk Event
    /// - Parameter event: MIDI File Chunk Event
    init?(fileEvent event: MIDIFileChunkEvent) {
        guard
            let metaEvent = MIDICustomMetaEvent(data: event.computedData)
        else {
            return nil
        }
        self = metaEvent
        if event.timeFormat == .ticksPerBeat {
            positionInBeats = event.position
        }
    }

    /// Event data
    public let data: [MIDIByte]
    /// Event type
    public let type: MIDICustomMetaEventType
    /// Event length
    public let length: Int
    /// Printable string
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

    /// Event name as retrieve from the data suffix
    public var name: String? {
        return String(bytes: data.suffix(length), encoding: .utf8)
    }

}
