//
//  AKSequencer.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Basic sequencer
///
/// This  is currently in transistion from old c core audio apis, to the more
/// modern avaudiosequencer setup. However, the new system is not as advanced as the
/// old, so we will keep both and have them interact. In addition, some of the features
/// of the new AVAudioSequencer don't even work yet (midi sequencing).
/// Still, both have their strengths and weaknesses so I am keeping them both.
/// As such, there is some code hanging around while we iron it out.
///
public class AKSequencer {
    
    /// Music sequence
    public var sequence: MusicSequence = nil
    
    /// Pointer to Music Sequence
    public var sequencePointer: UnsafeMutablePointer<MusicSequence>
    
    /// AVAudioSequencer - on hold while technology is still unstable
    public var avSeq = AVAudioSequencer()
    
    /// Array of AudioKit Music Tracks
    public var tracks: [AKMusicTrack] = []
    
    /// Array of AVMusicTracks
    public var avTracks: [AVMusicTrack] {
        if isAvSeq {
            return avSeq.tracks
        } else {
            //this won't do anything if not using an AVSeq
            let tracks: [AVMusicTrack] = []
            return tracks
        }
    }
    
    /// Music Player
    var musicPlayer: MusicPlayer = nil
    
    /// Loop control
    public var loopEnabled: Bool = false
    
    /// Are we using the AVAudioEngineSequencer?
    public var isAvSeq: Bool = false
    
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
        loadMIDIFile(filename)
    }
    
    /// Initialize the sequence with a midi file and audioengine
    ///
    /// - parameter filename: Location of the MIDI File
    /// - parameter engine: reference to the AV Audio Engine
    /// - on hold while technology is still unstable
    ///
    public convenience init(filename: String, engine: AVAudioEngine) {
        self.init()
        isAvSeq = true
        avSeq = AVAudioSequencer(audioEngine: engine)
        loadMIDIFile(filename)
    }
    
    /// Initialize the sequence with an empty sequence and audioengine
    ///
    /// - parameter engine: reference to the AV Audio Engine
    /// - on hold while technology is still unstable
    ///
    public convenience init(engine: AVAudioEngine) {
        self.init()
        isAvSeq = true
        avSeq = AVAudioSequencer(audioEngine: engine)
    }
    
    /// Load a sequence from data
    ///
    /// - parameter data: data to create sequence from
    ///
    public func sequenceFromData(data: NSData) {
        let options = AVMusicSequenceLoadOptions.SMF_PreserveTracks
        
        do {
            try avSeq.loadFromData(data, options: options)
            print("should have loaded new sequence data")
        } catch {
            print("cannot load from data \(error)")
            return
        }
    }
    
    /// Preroll for the music player
    public func preRoll() {
        MusicPlayerStop(musicPlayer)
        MusicPlayerPreroll(musicPlayer)
    }
    
    /// Set loop functionality of entire sequence
    public func loopToggle() {
        (loopEnabled ? loopOff() : loopOn())
    }
    
    /// Enable looping for all tracks - loops entire sequence
    public func loopOn() {
        if isAvSeq {
            for track in avSeq.tracks{
                track.loopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length)
            }
        } else {
            setLoopInfo(length, numberOfLoops: 0)
        }
        loopEnabled = true
    }
    
    /// Enable looping for all tracks with specified length
    public func loopOn(loopLength:Double) {
        if isAvSeq {
            for track in avSeq.tracks{
                track.loopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length)
            }
        } else {
            setLoopInfo(loopLength, numberOfLoops: 0)
        }
        loopEnabled = true
    }
    
    /// Disable looping for all tracks
    public func loopOff() {
        if isAvSeq {
            for track in avSeq.tracks{
                track.loopingEnabled = false
            }
        } else {
            setLoopInfo(0, numberOfLoops: 0)
        }
        loopEnabled = false
    }
    
    ///  Set looping duration and count for all tracks
    ///
    /// - parameter duration: Duration of the loop in seconds
    /// - parameter numberOfLoops: The number of time to repeat
    ///
    public func setLoopInfo(duration: Double, numberOfLoops: Int) {
        if isAvSeq {
            //nothing yet
        } else {
            for track in tracks{
                track.setLoopInfo(duration, numberOfLoops: numberOfLoops)
            }
        }
    }
    
    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in seconds
    ///
    public func setLength(length: Double) {
        for track in tracks {
            track.setLength(length)
        }
        if isAvSeq {
            for track in avSeq.tracks {
                track.lengthInBeats = length
                track.loopRange = AVMakeBeatRange(0, length)
            }
        }
    }
    
    /// Length of longest track in the sequence
    public var length: Double {
        
        var length:    MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0
        
        for track in tracks {
            tmpLength = track.length
            if(tmpLength >= length) { length = tmpLength }
        }
        
        if isAvSeq {
            for track in avSeq.tracks {
                tmpLength = track.lengthInBeats
                if(tmpLength >= length) { length = tmpLength }
            }
        }
        return Double(length)
    }
    
    /// Set the rate relative to the the default BPM of the track
    public func setRate(rate: Float) {
        if isAvSeq {
            avSeq.rate = rate
        } else {
            //not applicable
        }
    }
    
    /// Set the tempo of the sequencer
    public func setBPM(bpm: Double) {
        if isAvSeq {
            //not applicable
        } else {
            var newTempo = bpm;
            if newTempo > 280 { newTempo = 280 } //bpm limits
            if newTempo < 10  { newTempo = 10  }
            
            var tempoTrack: MusicTrack = nil
            
            MusicSequenceGetTempoTrack(sequence, &tempoTrack)
            if(isPlaying){
                var currTime: MusicTimeStamp = 0
                MusicPlayerGetTime(musicPlayer, &currTime)
                currTime = fmod(currTime, length)
                MusicTrackNewExtendedTempoEvent(tempoTrack, currTime, Double(newTempo))
            }
            MusicTrackClear(tempoTrack, 0, length)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, Double(newTempo))
        }
    }
    
    /// Add a  tempo change to the score
    ///
    /// - parameter bpm: Tempo in beats per minute
    /// - parameter position: Point in time in seconds
    ///
    public func addTempoEvent(bpm: Double, position: Double) {
        if isAvSeq {
            //not applicable
        } else {
            var newTempo = bpm;
            if newTempo > 280 { newTempo = 280 } //bpm limits
            if newTempo < 10  { newTempo = 10  }
            
            var tempoTrack: MusicTrack = nil
            
            MusicSequenceGetTempoTrack(sequence, &tempoTrack)
            MusicTrackNewExtendedTempoEvent(tempoTrack, position, Double(newTempo))
        }

    }
    
    /// Convert seconds into beats
    ///
    /// - parameter seconds: time in seconds
    ///
    public func beatsForSeconds(seconds: Double) -> Double {
        var outBeats: Double = MusicTimeStamp()
        MusicSequenceGetBeatsForSeconds(sequence, Float64(seconds), &outBeats)
        return outBeats
    }
    
    /// Convert beats into seconds
    ///
    /// - parameter beats: number of beats (can be fractional)
    ///
    public func secondsForBeats(beats: Double) -> Double {
        var outSecs: Double = MusicTimeStamp()
        MusicSequenceGetSecondsForBeats(sequence, beats, &outSecs)
        return outSecs
    }
    
    /// Play the sequence
    public func play() {
        if isAvSeq {
            do{
                try avSeq.start()
            } catch _ {
                print("could not start avSeq")
            }
        } else {
            MusicPlayerStart(musicPlayer)
        }
    }
    
    /// Stop the sequence
    public func stop() {
        if isAvSeq {
            avSeq.stop()
        } else {
            MusicPlayerStop(musicPlayer)
        }
    }
    
    /// Rewind the sequence
    public func rewind() {
        if isAvSeq {
            avSeq.currentPositionInBeats = 0
        } else {
            MusicPlayerSetTime(musicPlayer, 0)
        }
    }
    
    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    public func setGlobalAVAudioUnitOutput(audioUnit: AVAudioUnit) {
        if isAvSeq {
            for track in avSeq.tracks{
                track.destinationAudioUnit = audioUnit
            }
        } else {
           //do nothing - doesn't apply. In the old C-api, MusicTracks could point at AUNodes, but we don't use those
        }
    }
    
    /// Wheter or not the sequencer is currently playing
    public var isPlaying: Bool {
        if isAvSeq {
            return avSeq.playing
        } else {
            var isPlayingBool:DarwinBoolean = false
            MusicPlayerIsPlaying(musicPlayer, &isPlayingBool)
            return isPlayingBool.boolValue
        }
    }
    
    /// Current Time
    public var currentTime: Double {
        if isAvSeq {
            return avSeq.currentPositionInBeats
        } else {
            var currTime = MusicTimeStamp()
            MusicPlayerGetTime(musicPlayer, &currTime)
            return currTime
        }
    }
    
    /// Track count
    public var trackCount: Int {
        if isAvSeq {
            return avSeq.tracks.count
        } else {
            var count:UInt32 = 0
            MusicSequenceGetTrackCount(sequence, &count)
            return Int(count)
        }
    }
    
    /// Load a MIDI file
    public func loadMIDIFile(filename:String) {
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource(filename, ofType: "mid")
        let fileURL = NSURL.fileURLWithPath(file!)
        MusicSequenceFileLoad(sequence, fileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        if isAvSeq {
            do {
               try avSeq.loadFromURL(fileURL, options: AVMusicSequenceLoadOptions.SMF_PreserveTracks)
            }catch _ {
                print("failed to load midi into avseq")
            }
        }
        initTracks()
    }
    
    /// Initialize all tracks
    ///
    /// Clears the AKMusicTrack array, and rebuilds it based on actual contents of music sequence
    ///
    func initTracks() {
        tracks.removeAll()
        
        var count: UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &count)

        for i in 0 ..< count {
            var musicTrack: MusicTrack = nil
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            tracks.append(AKMusicTrack(musicTrack: musicTrack))
        }
    }
    
    /// Get a new track
    public func newTrack()->AKMusicTrack? {
        if(!isAvSeq){
            var newMusicTrack: MusicTrack = nil
            MusicSequenceNewTrack(sequence, &newMusicTrack)
            var count: UInt32 = 0
            MusicSequenceGetTrackCount(sequence, &count)
            tracks.append(AKMusicTrack(musicTrack: newMusicTrack))
            initTracks()
            return tracks.last!
        }else{
            //cannot
            return nil
        }
    }
    
    /// Clear some events from the track
    public func clearRange(start:Double, duration:Double) {
        if(isAvSeq){
            //?
        }else{
            for track in tracks{
                track.clearRange(start, duration: duration)
            }
        }
    }
    
    /// Set the music player time directly
    ///
    /// - parameter time: Music time stamp to set
    ///
    public func setTime(time: MusicTimeStamp){
        MusicPlayerSetTime(musicPlayer, time)
    }
    
    /// Generate NSData from the sequence
    public func genData() -> NSData? {
        var status = OSStatus(noErr)
        var data: Unmanaged<CFData>?
        status = MusicSequenceFileCreateData(sequence,
                                             MusicSequenceFileTypeID.MIDIType,
                                             MusicSequenceFileFlags.EraseFile,
                                             480, &data)
        if status != noErr {
            print("error creating MusicSequence Data")
            return nil
        }
        let ns: NSData = data!.takeUnretainedValue()
        data?.release()
        return ns
    }
    
    /// Print sequence to console
    public func debug() {
        if isAvSeq {
            print("No debug information available for AVAudioEngine's sequencer.")
        } else {
            CAShow(sequencePointer)
        }
    }
    
    public static func beatsFromSamples(samples:Int, fs:Int, bpm:Double)->Double{
        let timeInSecs = Double(samples)/Double(fs)
        let beatsPerSec = bpm/60.0
        let beatLenInSecs = Double(1.0/beatsPerSec)
        let numBeats = timeInSecs/beatLenInSecs
        return numBeats
    }
    public static func secondsFromBeats(beats:Double, bpm:Double)->Double{
        return (60.0/bpm)*beats
    }
}