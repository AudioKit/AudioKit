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
    
    /// Set loop functionality of entire sequence
    public func loopToggle() {
        (loopEnabled ? loopOff() : loopOn())
    }
    
    /// Enable looping for all tracks
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
    public func setBPM(bpm: Float) {
        if isAvSeq {
            //not applicable
        } else {
            var newTempo = bpm;
            if newTempo > 280 { newTempo = 280 } //bpm limits
            if newTempo < 10  { newTempo = 10  }
            
            var tempoTrack = MusicTrack()
            var currTime: MusicTimeStamp = 0
            MusicPlayerGetTime(musicPlayer, &currTime)
            currTime = fmod(currTime, length)
            
            MusicSequenceGetTempoTrack(sequence, &tempoTrack)
            MusicTrackNewExtendedTempoEvent(tempoTrack, currTime, Double(newTempo))
            MusicTrackClear(tempoTrack, 0, length)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, Double(newTempo))
        }
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

        for( var i = 0; i < Int(count); ++i) {
            var musicTrack = MusicTrack()
            MusicSequenceGetIndTrack(sequence, UInt32(i), &musicTrack)
            tracks.append(AKMusicTrack(musicTrack: musicTrack))
        }
    }
    
    /// Get a new track
    public func newTrack() {
        var newMusTrack = MusicTrack()
        MusicSequenceNewTrack(sequence, &newMusTrack)
        var count: UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &count)
        tracks.append(AKMusicTrack(musicTrack: newMusTrack))
        initTracks()
    }
    
    /// Print sequence to console
    public func debug() {
        if isAvSeq {
            print("No debug information available for AVAudioEngine's sequencer.")
        } else {
            CAShow(sequencePointer)
        }
    }
}