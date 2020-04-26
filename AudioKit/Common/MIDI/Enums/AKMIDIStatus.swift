// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public struct AKMIDIStatus: AKMIDIMessage {

    public var data: [UInt8] {
        return [byte]
    }

    public var byte: MIDIByte

    public init(type: AKMIDIStatusType, channel: MIDIChannel) {
        byte = MIDIByte(type.rawValue) << 4 + channel
    }

    public init(command: AKMIDISystemCommand) {
        byte = command.rawValue
    }

    public init?(byte: MIDIByte) {
        if AKMIDIStatusType.from(byte: byte) != nil {
            self.byte = byte
        } else {
            return nil
        }
    }

    public var type: AKMIDIStatusType? {
        return AKMIDIStatusType(rawValue: Int(byte.highBit))
    }

    public var channel: MIDIChannel {
        return byte.lowBit
    }

    public var description: String {
        if let type = self.type {
            return "\(type.description) channel \(channel)"
        } else if let command = AKMIDISystemCommand(rawValue: byte) {
            return "Command: \(command.description)"
        }
        return "Invalid message"
    }

    public var length: Int {
        return type?.length ?? 0
    }
}

/// Potential MIDI Status messages
///
/// - NoteOff:
///    something resembling a keyboard key release
/// - NoteOn:
///    triggered when a new note is created, or a keyboard key press
/// - PolyphonicAftertouch:
///    rare MIDI control on controllers in which every key has separate touch sensing
/// - ControllerChange:
///    wide range of control types including volume, expression, modulation
///    and a host of unnamed controllers with numbers
/// - ProgramChange:
///    messages are associated with changing the basic character of the sound preset
/// - ChannelAftertouch:
///    single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
/// - PitchWheel:
///    common keyboard control that allow for a pitch to be bent up or down a given number of semitones
///
public enum AKMIDIStatusType: Int {
    /// Note off is something resembling a keyboard key release
    case noteOff = 8
    /// Note on is triggered when a new note is created, or a keyboard key press
    case noteOn = 9
    /// Polyphonic aftertouch is a rare MIDI control on controllers in which
    /// every key has separate touch sensing
    case polyphonicAftertouch = 10
    /// Controller changes represent a wide range of control types including volume,
    /// expression, modulation and a host of unnamed controllers with numbers
    case controllerChange = 11
    /// Program change messages are associated with changing the basic character of the sound preset
    case programChange = 12
    /// A single aftertouch for all notes on a given channel
    /// (most common aftertouch type in keyboards)
    case channelAftertouch = 13
    /// A pitch wheel is a common keyboard control that allow for a pitch to be
    /// bent up or down a given number of semitones
    case pitchWheel = 14

    public static func from(byte: MIDIByte) -> AKMIDIStatusType? {
        return AKMIDIStatusType(rawValue: Int(byte.highBit))
    }

    public var length: Int {
        switch self {
        case .programChange, .channelAftertouch:
            return 2
        case .noteOff, .noteOn, .controllerChange, .pitchWheel, .polyphonicAftertouch:
            return 3
        }
    }

    public var description: String {
        switch self {
        case .noteOff:
            return "Note Off"
        case .noteOn:
            return "Note On"
        case .polyphonicAftertouch:
            return "Polyphonic Aftertouch / Pressure"
        case .controllerChange:
            return "Control Change"
        case .programChange:
            return "Program Change"
        case .channelAftertouch:
            return "Channel Aftertouch / Pressure"
        case .pitchWheel:
            return "Pitch Wheel"
        }
    }
}
