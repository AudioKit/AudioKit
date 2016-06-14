//
//  AKMusicTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Wrapper for internal Apple MusicTrack
public class AKMusicTrack {
    
    // MARK: - Properties
    
    /// The representation of Apple's underlying music track
    public var internalMusicTrack: MusicTrack? = nil
    
    private var name: String = "Unnamed"
    
    /// Sequencer this music track is part of
    public var sequencer = AKSequencer()
    
    /// Pointer to the Music Track
    public var trackPointer: UnsafeMutablePointer<MusicTrack>
    
    /// Total duration of the music track
    public var length: MusicTimeStamp {
        var size: UInt32 = 0
        var lengthFromMusicTimeStamp = MusicTimeStamp(0)
        MusicTrackGetProperty(internalMusicTrack!,
                              kSequenceTrackProperty_TrackLength,
                              &lengthFromMusicTimeStamp,
                              &size)
        return lengthFromMusicTimeStamp
    }
    
    // MARK: - Initialization
    
    /// Initialize with nothing
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public init() {
        trackPointer = UnsafeMutablePointer<MusicTrack>(internalMusicTrack!)
    }
    
    /// Initialize with a music track
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public convenience init(musicTrack: MusicTrack, name: String = "Unnamed") {
        self.init()
        self.name = name
        internalMusicTrack = musicTrack
        trackPointer = UnsafeMutablePointer<MusicTrack>(internalMusicTrack!)
        
        let data = [UInt8](name.utf8)
        
        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 3 // track or sequence name
        metaEvent.dataLength = UInt32(data.count)
        
        withUnsafeMutablePointer(&metaEvent.data, {
            ptr in
            for i in 0 ..< data.count {
                ptr[i] = data[i]
            }
        })

        print("Creating meta event for \(name)")
        let result = MusicTrackNewMetaEvent(internalMusicTrack!, MusicTimeStamp(0), &metaEvent)
        if result != 0 {
            print("Unable to name Track")
        }
    }
    
    /// Initialize with a music track and the AKSequence
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public convenience init(musicTrack: MusicTrack, sequencer: AKSequencer) {
        self.init()
        internalMusicTrack = musicTrack
        trackPointer = UnsafeMutablePointer<MusicTrack>(internalMusicTrack!)
        self.sequencer = sequencer
    }
    
    /// Set the Node Output
    ///
    /// - parameter node: Apple AUNode for output
    ///
    public func setNodeOutput(_ node: AUNode) {
        MusicTrackSetDestNode(internalMusicTrack!, node)
    }
    
    /// Set loop info
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    /// - paramter numberOfLoops: how many times to loop. 0 is infinte
    ///
    public func setLoopInfo(_ duration: Beat, numberOfLoops: Int) {
        let size: UInt32 = UInt32(sizeof(MusicTrackLoopInfo))
        let loopDuration = MusicTimeStamp(duration)
        var loopInfo = MusicTrackLoopInfo(loopDuration: loopDuration,
                                          numberOfLoops: Int32(numberOfLoops))
        MusicTrackSetProperty(internalMusicTrack!,
                              kSequenceTrackProperty_LoopInfo,
                              &loopInfo,
                              size)
    }
   
    /// Set length
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    /// If any of your notes are longer than the new length, this will truncate those notes
    /// This will truncate your sequence if you shorten it - so make a copy if you plan on doing that.
    ///
    public func setLength(_ duration: Beat) {
        
        let size: UInt32 = 0
        var len = MusicTimeStamp(duration)
        var tmpSeq: MusicSequence? = nil
        var seqPtr: UnsafeMutablePointer<MusicSequence>
        var tmpTrack: MusicTrack? = nil
        seqPtr = UnsafeMutablePointer<MusicSequence>(tmpSeq!)
        NewMusicSequence(&tmpSeq)
        MusicTrackGetSequence(internalMusicTrack!, seqPtr)
        MusicSequenceNewTrack(tmpSeq!, &tmpTrack)
        MusicTrackSetProperty(tmpTrack!, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(internalMusicTrack!, 0, len, tmpTrack!, 0)
        self.clear()
        MusicTrackSetProperty(internalMusicTrack!, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(tmpTrack!, 0, len, internalMusicTrack!, 0)
        MusicSequenceDisposeTrack(tmpSeq!, tmpTrack!)
        
        DisposeMusicSequence(tmpSeq!)

        //now to clean up any notes that are too long
        var iterator: MusicEventIterator? = nil
        NewMusicEventIterator(internalMusicTrack!, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafePointer<Void>? = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false
        
        MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        
        while(hasNextEvent) {
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)
            
            if eventType == kMusicEventType_MIDINoteMessage {
                let data = UnsafePointer<MIDINoteMessage>(eventData)
                let channel = data?.pointee.channel
                let note = data?.pointee.note
                let velocity = data?.pointee.velocity
                let dur = data?.pointee.duration
                
                if Beat(eventTime) + Beat(dur!) > duration {
                    var newNote = MIDINoteMessage(channel: channel!, note: note!, velocity: velocity!, releaseVelocity: 0, duration: Float32(Beat(duration) - Beat(eventTime)))
                    MusicEventIteratorSetEventInfo(iterator!, eventType, &newNote)
                }
            }
            
            MusicEventIteratorNextEvent(iterator!)
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        }
        DisposeMusicEventIterator(iterator!)
    }
    
    /// A less destructive and simpler way to set the length
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    ///
    public func setLengthSoft(_ duration: Beat) {
        let size: UInt32 = 0
        var len = MusicTimeStamp(duration)
        MusicTrackSetProperty(internalMusicTrack!, kSequenceTrackProperty_TrackLength, &len, size)
    }
    
    /// Clear all events from the track
    public func clear() {
        MusicTrackClear(internalMusicTrack!, 0, length)
    }
    
    /// Clear some events from the track
    ///
    /// - parameter start:    Start of the range to clear, in beats
    /// - parameter duration: Duration of the range to clear, in beats
    ///
    public func clearRange(_ start: Beat, duration: Beat) {
        MusicTrackClear(internalMusicTrack!, start, duration)
    }
    
    /// Add Note to sequence
    ///
    /// - parameter note: The midi note number to insert
    /// - parameter velocity: The velocity to insert note at
    /// - parameter position: Where in the sequence to start the note (expressed in beats)
    /// - parameter duration: How long to hold the note (would be better if they let us just use noteOffs...oh well)
    /// - parameter channel: MIDI channel for this note
    ///
    public func addNote(_ note: Int, velocity: Int, position: Beat, duration: Beat, channel: Int = 0) {
        
        var noteMessage = MIDINoteMessage(
            channel: UInt8(channel),
            note: UInt8(note),
            velocity: UInt8(velocity),
            releaseVelocity: 0,
            duration: Float32(duration))
        
        MusicTrackNewMIDINoteEvent(internalMusicTrack!, MusicTimeStamp(position), &noteMessage)
    }
    /// Add Controller change to sequence
    ///
    /// - parameter controller: The midi controller to insert
    /// - parameter value: The velocity to insert note at
    /// - parameter position: Where in the sequence to start the note (expressed in beats)
    /// - parameter channel: MIDI channel for this note
    ///
    public func addController(_ controller: Int, value: Int, position: Beat, channel: Int = 0) {
        
        var controlMessage = MIDIChannelMessage(status: UInt8(11 << 4) | UInt8((channel) & 0xf), data1: UInt8(controller), data2: UInt8(value), reserved: 0)
        MusicTrackNewMIDIChannelEvent(internalMusicTrack!, MusicTimeStamp(position), &controlMessage)
    }
    
    /// Debug by showing the track pointer.
    public func debug() {
        CAShow(trackPointer)
    }
}
