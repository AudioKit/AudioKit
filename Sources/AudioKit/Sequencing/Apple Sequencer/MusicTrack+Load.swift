// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension MusicTrackManager {
    func loadMIDI(filePath: String) {
        Log("loading file from exists @ \(filePath)")
        let fileURL = URL(fileURLWithPath: filePath)
        var tempSeq: MusicSequence?
        NewMusicSequence(&tempSeq)
        if let newSeq = tempSeq {
            let status: OSStatus = MusicSequenceFileLoad(newSeq, fileURL as CFURL, .midiType, MusicSequenceLoadFlags())
            if status != OSStatus(noErr) {
                Log("error reading midi file url: \(fileURL), read status: \(status)")
            }
            var trackCount = UInt32(0)
            MusicSequenceGetTrackCount(newSeq, &trackCount)
            Log("Sequencer has \(trackCount) tracks")
            var tempTrack: MusicTrack?
            MusicSequenceGetIndTrack(newSeq, 0, &tempTrack)
            if let sourceTrack = tempTrack, let destTrack = internalMusicTrack {
                MusicTrackCopyInsert(sourceTrack, 0, length, destTrack, 0)
                var tempIterator: MusicEventIterator?
                NewMusicEventIterator(sourceTrack, &tempIterator)
                if let iterator = tempIterator {
                    var hasEvent = DarwinBoolean(false)
                    MusicEventIteratorHasCurrentEvent(iterator, &hasEvent)
                    var i = 0
                    while hasEvent.boolValue {
                        MusicEventIteratorNextEvent(iterator)
                        var eventTime = MusicTimeStamp(0)
                        var eventType = MusicEventType(0)
                        var eventData: UnsafeRawPointer?
                        var eventDataSize: UInt32 = 0
                        MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)
                        if let event = MusicTrackManagerEventType(rawValue: eventType) {
                            Log("event \(i) at time \(eventTime) type is \(event.description)")
                        }
                        MusicEventIteratorHasCurrentEvent(iterator, &hasEvent)
                        i += 1
                    }
                }
            }
        }
    }
}

enum MusicTrackManagerEventType: UInt32 {
    case kMusicEventType_NULL = 0
    case kMusicEventType_ExtendedNote = 1
    case undefined2 = 2
    case kMusicEventType_ExtendedTempo = 3
    case kMusicEventType_User = 4
    case kMusicEventType_Meta = 5
    case kMusicEventType_MIDINoteMessage = 6
    case kMusicEventType_MIDIChannelMessage = 7
    case kMusicEventType_MIDIRawData = 8
    case kMusicEventType_Parameter = 9
    case kMusicEventType_AUPreset = 10

    var description: String {
        switch self {
        case .kMusicEventType_NULL:
            return "kMusicEventType_NULL"
        case .kMusicEventType_ExtendedNote:
            return "kMusicEventType_ExtendedNote"
        case .kMusicEventType_ExtendedTempo:
            return "kMusicEventType_ExtendedTempo"
        case .kMusicEventType_User:
            return "kMusicEventType_User"
        case .kMusicEventType_Meta:
            return "kMusicEventType_Meta"
        case .kMusicEventType_MIDINoteMessage:
            return "kMusicEventType_MIDINoteMessage"
        case .kMusicEventType_MIDIChannelMessage:
            return "kMusicEventType_MIDIChannelMessage"
        case .kMusicEventType_MIDIRawData:
            return "kMusicEventType_MIDIRawData"
        case .kMusicEventType_Parameter:
            return "kMusicEventType_Parameter"
        case .kMusicEventType_AUPreset:
            return "kMusicEventType_AUPreset"
        default:
            return "undefined"
        }
    }
}
