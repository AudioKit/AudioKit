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
    public var internalMusicTrack: MusicTrack = nil
    
    /// Pointer to the Music Track
    public var trackPtr: UnsafeMutablePointer<MusicTrack>
    
    /// Total duration of the music track
    public var length: MusicTimeStamp {
        var size: UInt32 = 0
        var lengthFromMusicTimeStamp = MusicTimeStamp(0)
        MusicTrackGetProperty(internalMusicTrack,
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
        trackPtr = UnsafeMutablePointer<MusicTrack>(internalMusicTrack)
    }
    
    /// Initialize with a music track
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public convenience init(musicTrack: MusicTrack) {
        self.init()
        internalMusicTrack = musicTrack
        trackPtr = UnsafeMutablePointer<MusicTrack>(internalMusicTrack)
    }
    
    /// Set the Node Output
    ///
    /// - parameter node: Apple AUNode for output
    ///
    public func setNodeOutput(node: AUNode) {
        MusicTrackSetDestNode(internalMusicTrack, node)
    }
    
    /// Set loop info
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    /// - paramter numberOfLoops: how many times to loop. 0 is infinte
    ///
    public func setLoopInfo(duration: Double, numberOfLoops: Int) {
        let size: UInt32 = UInt32(sizeof(MusicTrackLoopInfo))
        let loopDuration = MusicTimeStamp(duration)
        var loopInfo = MusicTrackLoopInfo(loopDuration: loopDuration,
                                          numberOfLoops: Int32(numberOfLoops))
        MusicTrackSetProperty(internalMusicTrack,
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
    public func setLength(duration: Double) {
        
        let size: UInt32 = 0
        var len = MusicTimeStamp(duration)
        var tmpSeq: MusicSequence = nil
        var seqPtr: UnsafeMutablePointer<MusicSequence>
        var tmpTrack: MusicTrack = nil
        seqPtr = UnsafeMutablePointer<MusicSequence>(tmpSeq)
        NewMusicSequence(&tmpSeq)
        MusicTrackGetSequence(internalMusicTrack, seqPtr)
        MusicSequenceNewTrack(tmpSeq, &tmpTrack)
        MusicTrackSetProperty(tmpTrack, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(internalMusicTrack, 0, len, tmpTrack, 0)
        self.clear()
        MusicTrackSetProperty(internalMusicTrack, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(tmpTrack, 0, len, internalMusicTrack, 0)
        MusicSequenceDisposeTrack(tmpSeq, tmpTrack)
        
        DisposeMusicSequence(tmpSeq)

        //now to clean up any notes that are too long
        var iterator: MusicEventIterator = nil
        NewMusicEventIterator(internalMusicTrack, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafePointer<Void> = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false
        
        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        
        while(hasNextEvent) {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)
            
            if eventType == kMusicEventType_MIDINoteMessage {
                let data = UnsafePointer<MIDINoteMessage>(eventData)
                let channel = data.memory.channel
                let note = data.memory.note
                let velocity = data.memory.velocity
                let dur = data.memory.duration
                
                if Double(eventTime) + Double(dur) > duration {
                    //print("note is too long at \(Double(eventTime) + Double(dur))")
                    //print("newDur should be \(Double(duration) - Double(eventTime))")
                    var newNote = MIDINoteMessage(channel: channel, note: note, velocity: velocity, releaseVelocity: 0, duration: Float32(Double(duration) - Double(eventTime)))
                    MusicEventIteratorSetEventInfo(iterator, eventType, &newNote)
                }
                //print("time: \(eventTime) - chan:\(channel) - note:\(note) - vel:\(velocity) - duration:\(dur)")
            }
            
            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
            //print(hasNextEvent)
        }
        DisposeMusicEventIterator(iterator)
    }
    
    /// A less destructive and simpler way to set the length
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    ///
    public func setLengthSoft(duration: Double) {
        let size: UInt32 = 0
        var len = MusicTimeStamp(duration)
        MusicTrackSetProperty(internalMusicTrack, kSequenceTrackProperty_TrackLength, &len, size)
    }
    
    /// Clear all events from the track
    public func clear() {
        MusicTrackClear(internalMusicTrack, 0, length)
    }
    /// Clear some events from the track
    public func clearRange(start: Double, duration: Double) {
        MusicTrackClear(internalMusicTrack, start, duration)
    }
    
    /// Add Note to sequence
    ///
    /// - parameter note: The midi note number to insert
    /// - parameter velocity: The velocity to insert note at
    /// - parameter position: Where in the sequence to start the note (expressed in beats)
    /// - parameter duration: How long to hold the note (would be better if they let us just use noteOffs...oh well)
    /// - parameter channel: MIDI channel for this note
    ///
    public func addNote(note: Int, velocity: Int, position: Double, duration: Double, channel: Int = 0) {
        
        var noteMessage = MIDINoteMessage(
            channel: UInt8(channel),
            note: UInt8(note),
            velocity: UInt8(velocity),
            releaseVelocity: 0,
            duration: Float32(duration))
        
        MusicTrackNewMIDINoteEvent(internalMusicTrack, MusicTimeStamp(position), &noteMessage)
    }
    
    /// Debug by showing the track pointer.
    public func debug() {
        CAShow(trackPtr)
    }
}
