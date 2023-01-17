// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Foundation
import MIDI
import Utilities

public extension MusicTrackManager {
    /// Array of Apple MIDI Events
    var eventData: [AppleMIDIEvent]? {
        return getRawEventData()
    }

    /// Array of Apple MIDI Events
    var noteData: [AppleMIDIEvent]? {
        return getRawEventData(ofType: kMusicEventType_MIDINoteMessage)
    }

    /// Array of MIDI Program Change Events
    var programChangeEvents: [MIDIEvent.ProgramChange] {
        guard let appleMIDIEvents = eventData else { return [] }
        
        let pgmEvents: [MIDIEvent.ProgramChange] = appleMIDIEvents.reduce(into: []) { pgmEvents, appleMIDIEvent in
            guard appleMIDIEvent.type == kMusicEventType_MIDIChannelMessage else { return }
            
            let data = appleMIDIEvent.data?.bindMemory(to: MIDIChannelMessage.self, capacity: 1)
            guard let programNumber = data?.pointee.data1.toUInt7Exactly,
                  let statusData: MIDIByte = data?.pointee.status
            else {
                return
            }
            let isProgramChangeStatus = statusData.nibbles.high == 0xC
            let channel = statusData.nibbles.low
            if isProgramChangeStatus {
                let pgmEvent = MIDIEvent.ProgramChange(program: programNumber, bank: .noBankSelect, channel: channel)
                pgmEvents.append(pgmEvent)
            }
        }
        
        return pgmEvents
    }

    /// Get debug information
    func debug() {
        guard let events = eventData else {
            return
        }
        for event in events {
            switch event.type {
            case kMusicEventType_MIDINoteMessage:
                let data = event.data?.bindMemory(to: MIDINoteMessage.self, capacity: 1)
                guard let channel = data?.pointee.channel,
                      let note = data?.pointee.note,
                      let velocity = data?.pointee.velocity,
                      let dur = data?.pointee.duration
                else {
                    Log("Problem with raw midi note message")
                    return
                }
                Log("MIDI Note @:\(event.time) note:\(note) velocity:\(velocity) duration:\(dur) channel:\(channel)")
            case kMusicEventType_Meta:
                let data = event.data?.bindMemory(to: MIDIMetaEvent.self, capacity: 1)
                guard let midiData = data?.pointee.data,
                      let length = data?.pointee.dataLength,
                      let type = data?.pointee.metaEventType
                else {
                    Log("Problem with raw midi meta message")
                    return
                }
                Log("MIDI Meta @ \(event.time) - size: \(length) - type: \(type) - data: \(midiData)")
            case kMusicEventType_MIDIChannelMessage:
                let data = event.data?.bindMemory(to: MIDIChannelMessage.self, capacity: 1)
                guard let data1 = data?.pointee.data1,
                      let data2 = data?.pointee.data2,
                      let statusData = data?.pointee.status
                else {
                    Log("Problem with raw midi channel message")
                    return
                }
                let channel = statusData.nibbles.low
                let statusByte = statusData.nibbles.high
                let isProgramChangeStatus = statusByte == 0xC
                if isProgramChangeStatus {
                    switch isProgramChangeStatus {
                    case true:
                        Log("MIDI Program Change @ \(event.time) - program: \(data1) - channel: \(channel)")
                    case false:
                        Log("MIDI Channel Message @\(event.time) data1:\(data1) data2:\(data2) status:\(statusByte)")
                    }
                }
            default:
                Log("MIDI Event @ \(event.time)")
            }
        }
    }

    private func getRawEventData(ofType type: MusicEventType? = nil) -> [AppleMIDIEvent]? {
        var events: [AppleMIDIEvent]?
        guard let track = internalMusicTrack else {
            Log("debug failed - track doesn't exist")
            return events
        }

        events = [AppleMIDIEvent]()

        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        var iterator: MusicEventIterator!
        NewMusicEventIterator(track, &iterator)
        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)

        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)
            if type == nil || type == eventType,
               let data = eventData
            {
                events?.append(AppleMIDIEvent(time: eventTime, type: eventType, data: data, dataSize: eventDataSize))
            }
            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }
        DisposeMusicEventIterator(iterator)
        return events
    }
}

/// Apple MIDI Event
public struct AppleMIDIEvent {
    /// Start time
    public var time: MusicTimeStamp
    /// Event type
    public var type: MusicEventType
    /// Data contained in the event
    public var data: UnsafeRawPointer?
    /// Size of data
    public var dataSize: UInt32
}
