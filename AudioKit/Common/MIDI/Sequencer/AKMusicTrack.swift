//
//  AKMusicTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Wrapper for internal Apple MusicTrack
open class AKMusicTrack {

    // MARK: - Properties

    /// The representation of Apple's underlying music track
    open var internalMusicTrack: MusicTrack?

    fileprivate var name: String = "Unnamed"

    /// Sequencer this music track is part of
    open var sequencer = AKSequencer()

    /// Pointer to the Music Track
    open var trackPointer: UnsafeMutablePointer<MusicTrack>

    /// Total duration of the music track
    open var length: MusicTimeStamp {
        var size: UInt32 = 0
        var lengthFromMusicTimeStamp = MusicTimeStamp(0)
        MusicTrackGetProperty(internalMusicTrack!,
                              kSequenceTrackProperty_TrackLength,
                              &lengthFromMusicTimeStamp,
                              &size)
        return lengthFromMusicTimeStamp
    }

    // MARK: - Initialization

    /// Initialize with a music track
    ///
    /// - parameter musicTrack: An Apple Music Track
    /// - parameter name: Name for the track
    ///
    public init(musicTrack: MusicTrack, name: String = "Unnamed") {
        self.name = name
        internalMusicTrack = musicTrack
        trackPointer = UnsafeMutablePointer<MusicTrack>(internalMusicTrack!)

        let data = [MIDIByte](name.utf8)

        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 3 // track or sequence name
        metaEvent.dataLength = UInt32(data.count)

        withUnsafeMutablePointer(to: &metaEvent.data, { pointer in
            for i in 0 ..< data.count {
                pointer[i] = data[i]
            }
        })

        let result = MusicTrackNewMetaEvent(internalMusicTrack!, MusicTimeStamp(0), &metaEvent)
        if result != 0 {
            AKLog("Unable to name Track")
        }
    }

    /// Initialize with a music track and the AKSequence
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public init(musicTrack: MusicTrack, sequencer: AKSequencer) {
        internalMusicTrack = musicTrack
        trackPointer = UnsafeMutablePointer<MusicTrack>(internalMusicTrack!)
        self.sequencer = sequencer
    }

    /// Set the Node Output
    ///
    /// - parameter node: Apple AUNode for output
    ///
    open func setNodeOutput(_ node: AUNode) {
        MusicTrackSetDestNode(internalMusicTrack!, node)
    }

    /// Set loop info
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    /// - paramter numberOfLoops: how many times to loop. 0 is infinte
    ///
    open func setLoopInfo(_ duration: AKDuration, numberOfLoops: Int) {
        let size: UInt32 = UInt32(MemoryLayout<MusicTrackLoopInfo>.size)
        let loopDuration = duration.musicTimeStamp
        var loopInfo = MusicTrackLoopInfo(loopDuration: loopDuration,
                                          numberOfLoops: Int32(numberOfLoops))
        MusicTrackSetProperty(internalMusicTrack!,
                              kSequenceTrackProperty_LoopInfo,
                              &loopInfo,
                              size)
    }

    /// Set length
    /// If any of your notes are longer than the new length, this will truncate those notes
    /// This will truncate your sequence if you shorten it - so make a copy if you plan on doing that.
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    ///
    open func setLength(_ duration: AKDuration) {
        let size: UInt32 = 0
        var len = duration.musicTimeStamp
        var tmpSeq: MusicSequence? = nil
        var tmpTrack: MusicTrack? = nil
        NewMusicSequence(&tmpSeq)
        MusicSequenceNewTrack(tmpSeq!, &tmpTrack)
        MusicTrackSetProperty(tmpTrack!, kSequenceTrackProperty_TrackLength, &len, size)

        if !isEmpty {
            MusicTrackCopyInsert(internalMusicTrack!, 0, len, tmpTrack!, 0)
            clear()
            MusicTrackSetProperty(internalMusicTrack!, kSequenceTrackProperty_TrackLength, &len, size)
            MusicTrackCopyInsert(tmpTrack!, 0, len, internalMusicTrack!, 0)
            MusicSequenceDisposeTrack(tmpSeq!, tmpTrack!)

            DisposeMusicSequence(tmpSeq!)

            //now to clean up any notes that are too long
            var iterator: MusicEventIterator? = nil
            NewMusicEventIterator(internalMusicTrack!, &iterator)
            var eventTime = MusicTimeStamp(0)
            var eventType = MusicEventType()
            var eventData: UnsafeRawPointer? = nil
            var eventDataSize: UInt32 = 0
            var hasNextEvent: DarwinBoolean = false

            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)

            while hasNextEvent.boolValue {
                MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)

                if eventType == kMusicEventType_MIDINoteMessage {
                    let data = UnsafePointer<MIDINoteMessage>(eventData?.assumingMemoryBound(to: MIDINoteMessage.self))
                    let channel = data?.pointee.channel
                    let note = data?.pointee.note
                    let velocity = data?.pointee.velocity
                    let dur = data?.pointee.duration

                    if eventTime + dur! > duration.beats {
                        var newNote = MIDINoteMessage(channel: channel!, note: note!, velocity: velocity!, releaseVelocity: 0, duration: Float32(duration.beats - eventTime))
                        MusicEventIteratorSetEventInfo(iterator!, eventType, &newNote)
                    }
                }

                MusicEventIteratorNextEvent(iterator!)
                MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
            }
            DisposeMusicEventIterator(iterator!)
        } else {
            MusicTrackSetProperty(internalMusicTrack!, kSequenceTrackProperty_TrackLength, &len, size)
        }
    }

    /// A less destructive and simpler way to set the length
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    ///
    open func setLengthSoft(_ duration: AKDuration) {
        let size: UInt32 = 0
        var len = duration.musicTimeStamp
        MusicTrackSetProperty(internalMusicTrack!, kSequenceTrackProperty_TrackLength, &len, size)
    }

    /// Clear all events from the track
    open func clear() {
        clearMetaEvents()
        if !isEmpty {
            MusicTrackClear(internalMusicTrack!, 0, length)
        }
    }

    func clearMetaEvents() {
        var iterator: MusicEventIterator? = nil
        NewMusicEventIterator(internalMusicTrack!, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)

            if eventType == kMusicEventType_Meta {
                MusicEventIteratorDeleteEvent(iterator!)
            }
            MusicEventIteratorNextEvent(iterator!)
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        }
    }

    open func clearNote(_ note: MIDINoteNumber) {
        var iterator: MusicEventIterator? = nil
        NewMusicEventIterator(internalMusicTrack!, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)
            if eventType == kMusicEventType_MIDINoteMessage {
                let convertedData = eventData?.load(as: MIDINoteMessage.self)

                if convertedData!.note == MIDIByte(note) {
                    MusicEventIteratorDeleteEvent(iterator!)
                }
            }
            MusicEventIteratorNextEvent(iterator!)
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        }
    }

    open var isEmpty: Bool {
        var outBool = true
        var iterator: MusicEventIterator? = nil
        NewMusicEventIterator(internalMusicTrack!, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false
        MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)

            outBool = false
            //AKLog("time is \(eventTime) - type is \(eventType)")
            //AKLog("data is \(eventData)")
            MusicEventIteratorNextEvent(iterator!)
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        }
        return outBool
    }

    /// Clear some events from the track
    ///
    /// - Parameters:
    ///   - start:    Start of the range to clear, in beats
    ///   - duration: Duration of the range to clear, in beats
    ///
    open func clearRange(start: AKDuration, duration: AKDuration) {
        if !isEmpty {
            MusicTrackClear(internalMusicTrack!, start.beats, duration.beats)
        }
    }

    /// Add Note to sequence
    ///
    /// - Parameters:
    ///   - noteNumber: The midi note number to insert
    ///   - velocity: The velocity to insert note at
    ///   - position: Where in the sequence to start the note (expressed in beats)
    ///   - duration: How long to hold the note (would be better if they let us just use noteOffs...oh well)
    ///   - channel: MIDI channel for this note
    ///
    open func add(noteNumber: MIDINoteNumber,
                  velocity: MIDIVelocity,
                  position: AKDuration,
                  duration: AKDuration,
                  channel: MIDIChannel = 0) {

        var noteMessage = MIDINoteMessage(
            channel: channel,
            note: noteNumber,
            velocity: velocity,
            releaseVelocity: 0,
            duration: Float32(duration.beats))

        MusicTrackNewMIDINoteEvent(internalMusicTrack!, position.musicTimeStamp, &noteMessage)
    }
    /// Add Controller change to sequence
    ///
    /// - Parameters:
    ///   - controller: The midi controller to insert
    ///   - value: The velocity to insert note at
    ///   - position: Where in the sequence to start the note (expressed in beats)
    ///   - channel: MIDI channel for this note
    ///
    open func addController(_ controller: MIDIByte, value: MIDIByte, position: AKDuration, channel: MIDIChannel = 0) {

        var controlMessage = MIDIChannelMessage(status: MIDIByte(11 << 4) | MIDIByte((channel) & 0xf), data1: controller, data2: value, reserved: 0)
        MusicTrackNewMIDIChannelEvent(internalMusicTrack!, position.musicTimeStamp, &controlMessage)
    }

    /// Add Sysex message to sequence
    ///
    /// - Parameters:
    ///   - data: The midi data byte array - standard sysex start and end messages are added automatically
    ///   - position: Where in the sequence to start the note (expressed in beats)
    ///
    open func addSysex(_ data: [MIDIByte], position: AKDuration) {
        var midiData = MIDIRawData()
        midiData.length = UInt32(data.count)

        withUnsafeMutablePointer(to: &midiData.data, { pointer in
            for i in 0 ..< data.count {
                pointer[i] = data[i]
            }
        })

        let result = MusicTrackNewMIDIRawDataEvent(internalMusicTrack!, position.musicTimeStamp, &midiData)
        if result != 0 {
            AKLog("Unable to insert raw midi data")
        }

    }

    /// Copy this track to another track
    ///
    /// - parameter musicTrack: Destination track to copy this track to
    ///
    open func copyAndMergeTo(musicTrack: AKMusicTrack) {
        MusicTrackMerge(internalMusicTrack!, 0.0, length, musicTrack.internalMusicTrack!, 0.0)
    }

    /// Set the MIDI Ouput
    ///
    /// - parameter endpoint: MIDI Endpoint Port
    ///
    open func setMIDIOutput(_ endpoint: MIDIEndpointRef) {
        MusicTrackSetDestMIDIEndpoint(internalMusicTrack!, endpoint)
    }

    /// Debug by showing the track pointer.
    open func debug() {
        CAShow(trackPointer)
    }
}
