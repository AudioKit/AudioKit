//
//  AKSequencer.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/27/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Basic sequencer
///
/// This  is currently in transistion from old c core audio apis, to the more
/// modern avaudiosequencer setup. Hwever, the new system is not as advanced as the
/// old, so we will keep both and have them interact.  As such, there is some code
/// hanging around while we iron it out.
///
public class AKSequencer {
    
    /// Music sequence
    public var sequence:MusicSequence = nil
    
    /// Pointer to Music Sequence
    public var sequencePointer:UnsafeMutablePointer<MusicSequence>
    
    /// AVAudioSequencer
    public var avSeq = AVAudioSequencer()
    
    /// Array of AudioKit Music Tracks
    public var tracks:[AKMusicTrack] = []
    
    /// Array of AVMusicTracks
    public var rawTracks:[AVMusicTrack] {
        return avSeq.tracks
    }
    
    /// Music Player
    var musicPlayer:MusicPlayer = nil
    
    /// Loop control
    public var loopEnabled:Bool = false
    
    /// Sequencer Initialization
    public init() {
        NewMusicSequence(&sequence)
        sequencePointer = UnsafeMutablePointer<MusicSequence>(sequence)
        
        //setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer, sequence)
    }
    
    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter filename: Location of the MIDI File
    ///
    public convenience init(filename: String) {
        self.init()
        loadMidiFile(filename)
    }
    
    /// Initialize the sequence with a midi file and audioengine
    ///
    /// - parameter filename: Location of the MIDI File
    /// - parameter engine: reference to the AV Audio Engine
    ///
    public convenience init(filename: String, engine: AVAudioEngine) {
        self.init()
        avSeq = AVAudioSequencer(audioEngine: engine)
        loadMidiFile(filename)
    }
    
    /// Set loop functionality of entire sequence
    public func loopToggle(){
        (loopEnabled ? loopOff() : loopOn())
    }
    
    /// Enable looping for all tracks
    public func loopOn() {
        setLoopInfo(length, numberOfLoops: 0)
        for track in avSeq.tracks{
            track.loopingEnabled = true
            track.loopRange = AVMakeBeatRange(0, self.length)
        }
        loopEnabled = true
    }
    
    /// Disable looping for all tracks
    public func loopOff() {
        setLoopInfo(0, numberOfLoops: 0)
        for track in avSeq.tracks{
            track.loopingEnabled = false
        }
        loopEnabled = false
    }
    
    ///  Set looping duration and count for all tracks
    ///
    /// - parameter duration: Duration of the loop in seconds
    /// - parameter numberOfLoops: The number of time to repeat
    ///
    public func setLoopInfo(duration: Double, numberOfLoops: Int) {
        let size:UInt32 = 0
        let len = MusicTimeStamp(duration)
        var loopInfo = MusicTrackLoopInfo(loopDuration: len, numberOfLoops: Int32(numberOfLoops))
        for( var i = 0; i < self.numberOfTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_LoopInfo, &loopInfo, size)
        }
    }
    
    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in seconds
    ///
    public func setLength(length: Double) {
        let size:UInt32 = 0
        var len = MusicTimeStamp(length)
        for( var i = 0; i < self.numberOfTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &len, size)
        }
        for track in avSeq.tracks{
            track.lengthInBeats = len
            track.loopRange = AVMakeBeatRange(0, self.length)
        }
    }
    
    /// Length of longest track in the sequence
    public var length: Double {
        var length:MusicTimeStamp = 0
        var tmpLength:MusicTimeStamp = 0
//        var size:UInt32 = 0
//        for( var i = 0; i < self.numTracks; ++i){
//            var musicTrack = MusicTrack()
//            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
//            MusicTrackGetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &tmpLength, &size)
//            if(tmpLength >= length){ length = tmpLength }
//        }
        for track in avSeq.tracks{
            tmpLength = track.lengthInBeats
            if(tmpLength >= length){ length = tmpLength }
        }
        return Double(length)
    }
    
    /// Play the sequence
    public func play() {
//        MusicPlayerStart(musicPlayer)
        do{
            try avSeq.start()
        }catch _{
            print("could not start avSeq")
        }
    }
    
    /// Stop the sequence
    public func stop() {
//        MusicPlayerStop(musicPlayer)
        avSeq.stop()
    }
    
    /// Rewind the sequence
    public func rewind() {
//        MusicPlayerSetTime(musicPlayer, 0)
        avSeq.currentPositionInBeats = 0
    }
    
    /// Set the midi output for all tracks
    public func setGlobalMidiOutput(midiEndpoint: MIDIEndpointRef) {
//        for trackInd in tracks{
//            MusicTrackSetDestMIDIEndpoint(trackInd.internalMusicTrack, midiEndpoint)
//        }
        for track in avSeq.tracks{
            track.destinationMIDIEndpoint = midiEndpoint
        }
    }
    
    /// Sert the Audio Unit output for all tracks
    public func setGlobalAVAudioUnitOutput(audioUnit: AVAudioUnit) {
        for track in avSeq.tracks{
            track.destinationAudioUnit = audioUnit
        }
    }
    
    /// Track count
    public var numberOfTracks: Int {
        var count:UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &count)
        return Int(count)
    }
    
    /// Load a MIDI file
    public func loadMidiFile(filename:String) {
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource(filename, ofType: "mid")
        let fileURL = NSURL.fileURLWithPath(file!)
        MusicSequenceFileLoad(sequence, fileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        
        do {
           try avSeq.loadFromURL(fileURL, options: AVMusicSequenceLoadOptions.SMF_PreserveTracks)
        }catch _ {
            print("failed to load midi into avseq")
        }
        initTracks()
    }
    
    /// Initialize all tracks
    func initTracks() {
        tracks.removeAll()
        for( var i = 0; i < self.numberOfTracks; ++i){
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            tracks.append(AKMusicTrack(musicTrack: musicTrack))
        }
    }
    
}