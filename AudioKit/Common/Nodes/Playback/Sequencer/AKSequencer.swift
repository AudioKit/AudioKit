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
    public var avSequencer = AVAudioSequencer()
    
    /// Array of AudioKit Music Tracks
    public var tracks = [AKMusicTrack]()
    
    /// Array of AVMusicTracks
    public var avTracks: [AVMusicTrack] {
        if isAVSequencer {
            return avSequencer.tracks
        } else {
            //this won't do anything if not using an AVSeq
            let tracks = [AVMusicTrack]()
            return tracks
        }
    }
    
    /// Music Player
    var musicPlayer: MusicPlayer = nil
    
    /// Loop control
    public var loopEnabled: Bool = false
    
    /// Are we using the AVAudioEngineSequencer?
    public var isAVSequencer: Bool = false
    
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
        isAVSequencer = true
        avSequencer = AVAudioSequencer(audioEngine: engine)
        loadMIDIFile(filename)
    }
    
    /// Initialize the sequence with an empty sequence and audioengine
    ///
    /// - parameter engine: reference to the AV Audio Engine
    /// - on hold while technology is still unstable
    ///
    public convenience init(engine: AVAudioEngine) {
        self.init()
        isAVSequencer = true
        avSequencer = AVAudioSequencer(audioEngine: engine)
    }
    
    /// Load a sequence from data
    ///
    /// - parameter data: data to create sequence from
    ///
    public func sequenceFromData(data: NSData) {
        let options = AVMusicSequenceLoadOptions.SMF_PreserveTracks
        
        do {
            try avSequencer.loadFromData(data, options: options)
            print("should have loaded new sequence data")
        } catch {
            print("cannot load from data \(error)")
            return
        }
    }
    
    /// Preroll for the music player
    public func preroll() {
        MusicPlayerPreroll(musicPlayer)
    }
    
    /// Set loop functionality of entire sequence
    public func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }
    
    /// Enable looping for all tracks - loops entire sequence
    public func enableLooping() {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.loopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length.value)
            }
        } else {
            setLoopInfo(length, numberOfLoops: 0)
        }
        loopEnabled = true
    }
    
    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    public func enableLooping(loopLength: Beat) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.loopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length.value)
            }
        } else {
            setLoopInfo(loopLength, numberOfLoops: 0)
        }
        loopEnabled = true
    }
    
    /// Disable looping for all tracks
    public func disableLooping() {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.loopingEnabled = false
            }
        } else {
            setLoopInfo(Beat(0), numberOfLoops: 0)
        }
        loopEnabled = false
    }
    
    ///  Set looping duration and count for all tracks
    ///
    /// - parameter duration: Duration of the loop in beats
    /// - parameter numberOfLoops: The number of time to repeat
    ///
    public func setLoopInfo(duration: Beat, numberOfLoops: Int) {
        if isAVSequencer {
            //nothing yet
        } else {
            for track in tracks {
                track.setLoopInfo(duration, numberOfLoops: numberOfLoops)
            }
        }
        loopEnabled = true
    }
    
    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    public func setLength(length: Beat) {
        for track in tracks {
            track.setLength(length)
        }
        
        let size: UInt32 = 0
        var len = length.musicTimeStamp
        var tempoTrack: MusicTrack = nil
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        MusicTrackSetProperty(tempoTrack, kSequenceTrackProperty_TrackLength, &len, size)
        
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.lengthInBeats = length.value
                track.loopRange = AVMakeBeatRange(0, length.value)
            }
        }
    }
    
    /// Length of longest track in the sequence
    public var length: Beat {
        
        var length: MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0
        
        for track in tracks {
            tmpLength = track.length
            if tmpLength >= length { length = tmpLength }
        }
        
        if isAVSequencer {
            for track in avSequencer.tracks {
                tmpLength = track.lengthInBeats
                if tmpLength >= length { length = tmpLength }
            }
        }
        return Beat(length)
    }
    
    /// Rate relative to the default tempo (BPM) of the track
    public var rate: Double? {
        get {
            if isAVSequencer {
                return Double(avSequencer.rate)
            } else {
                return nil
            }
        }
        set {
            if isAVSequencer {
                avSequencer.rate = Float(newValue!)
            }
        }
    }
    
    /// Set the tempo of the sequencer
    public func setTempo(bpm: Double) {
        if isAVSequencer { return }
        
        var newTempo = bpm
        if newTempo > 280 { newTempo = 280 } //bpm limits
        if newTempo < 10 { newTempo = 10 }
        
        var tempoTrack: MusicTrack = nil
        
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if isPlaying {
            var currTime: MusicTimeStamp = 0
            MusicPlayerGetTime(musicPlayer, &currTime)
            currTime = fmod(currTime, length.value)
            MusicTrackNewExtendedTempoEvent(tempoTrack, currTime, Double(newTempo))
        }
        MusicTrackClear(tempoTrack, 0, length.value)
        MusicTrackNewExtendedTempoEvent(tempoTrack, 0, Double(newTempo))
        
    }

    /// Add a  tempo change to the score
    ///
    /// - parameter bpm: Tempo in beats per minute
    /// - parameter position: Point in time in beats
    ///
    public func addTempoEventAt(tempo bpm: Double, position: Beat) {
        if isAVSequencer { return }

        var newTempo = bpm
        if newTempo > 280 { newTempo = 280 } //bpm limits
        if newTempo < 10 { newTempo = 10 }
        
        var tempoTrack: MusicTrack = nil
        
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        MusicTrackNewExtendedTempoEvent(tempoTrack, position.value, Double(newTempo))

    }
    
    public var tempo: Double {
        var tempoOut: Double = 0.0
        
        var tempoTrack: MusicTrack = nil
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        
        var iterator:MusicEventIterator = nil
        NewMusicEventIterator(tempoTrack, &iterator);
        
        var eventTime: MusicTimeStamp = 0
        var eventType: MusicEventType = kMusicEventType_ExtendedTempo
        var eventData: UnsafePointer<Void> = nil
        var eventDataSize: UInt32 = 0
        
        var hasPreviousEvent: DarwinBoolean = false
        MusicEventIteratorSeek(iterator,kMusicTimeStamp_EndOfTrack)
        MusicEventIteratorHasPreviousEvent(iterator, &hasPreviousEvent)
        while hasPreviousEvent {
            MusicEventIteratorPreviousEvent(iterator)
            // do work here
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize);
            if eventType == kMusicEventType_ExtendedTempo {
                let tempoEvent = eventData as! ExtendedTempoEvent
                dump(tempoEvent)
            }
            MusicEventIteratorHasPreviousEvent(iterator, &hasPreviousEvent);
        }

        return tempoOut
    }
    
    /// Convert seconds into beats
    ///
    /// - parameter seconds: time in seconds
    ///
    public func beatsForSeconds(seconds: Double) -> Beat {
        let sign = seconds > 0 ? 1.0 : -1.0
        let absoluteValueSeconds = fabs(seconds)
        var outBeats = Beat(MusicTimeStamp())
        MusicSequenceGetBeatsForSeconds(sequence, Float64(absoluteValueSeconds), &(outBeats.value))
        outBeats.value = outBeats.value * sign
        return outBeats
    }
    
    /// Convert beats into seconds
    ///
    /// - parameter beats: number of beats (can be fractional)
    ///
    public func secondsForBeats(beats: Beat) -> Double {
        let sign = beats.value > 0 ? 1.0 : -1.0
        let absoluteValueBeats = fabs(beats.value)
        var outSecs: Double = MusicTimeStamp()
        MusicSequenceGetSecondsForBeats(sequence, absoluteValueBeats, &outSecs)
        outSecs = outSecs * sign
        return outSecs
    }
    
    /// Play the sequence
    public func play() {
        if isAVSequencer {
            do {
                try avSequencer.start()
            } catch _ {
                print("could not start avSeq")
            }
        } else {
            MusicPlayerStart(musicPlayer)
        }
    }
    
    /// Stop the sequence
    public func stop() {
        if isAVSequencer {
            avSequencer.stop()
        } else {
            MusicPlayerStop(musicPlayer)
        }
    }
    
    /// Rewind the sequence
    public func rewind() {
        if isAVSequencer {
            avSequencer.currentPositionInBeats = 0
        } else {
            MusicPlayerSetTime(musicPlayer, 0)
        }
    }
    
    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    public func setGlobalAVAudioUnitOutput(audioUnit: AVAudioUnit) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.destinationAudioUnit = audioUnit
            }
        } else {
           //do nothing - doesn't apply. In the old C-api, MusicTracks could point at AUNodes, but we don't use those
        }
    }
    
    /// Wheter or not the sequencer is currently playing
    public var isPlaying: Bool {
        if isAVSequencer {
            return avSequencer.playing
        } else {
            var isPlayingBool: DarwinBoolean = false
            MusicPlayerIsPlaying(musicPlayer, &isPlayingBool)
            return isPlayingBool.boolValue
        }
    }
    
    /// Current Time
    public var currentPosition: Beat {
        if isAVSequencer {
            return Beat(avSequencer.currentPositionInBeats)
        } else {
            var currentTime = MusicTimeStamp()
            MusicPlayerGetTime(musicPlayer, &currentTime)
            return Beat(currentTime)
        }
    }
    
    /// Track count
    public var trackCount: Int {
        if isAVSequencer {
            return avSequencer.tracks.count
        } else {
            var count: UInt32 = 0
            MusicSequenceGetTrackCount(sequence, &count)
            return Int(count)
        }
    }
    
    /// Load a MIDI file
    public func loadMIDIFile(filename: String) {
        let bundle = NSBundle.mainBundle()
        let file = bundle.pathForResource(filename, ofType: "mid")
        let fileURL = NSURL.fileURLWithPath(file!)
        MusicSequenceFileLoad(sequence, fileURL, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks)
        if isAVSequencer {
            do {
               try avSequencer.loadFromURL(fileURL, options: AVMusicSequenceLoadOptions.SMF_PreserveTracks)
            } catch _ {
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
            tracks.append(AKMusicTrack(musicTrack: musicTrack, name: "InitializedTrack"))
        }
    }
    
    /// Get a new track
    public func newTrack(name: String = "Unnamed") -> AKMusicTrack? {
        if isAVSequencer { return nil }
        
        var newMusicTrack: MusicTrack = nil
        MusicSequenceNewTrack(sequence, &newMusicTrack)
        var count: UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &count)
        tracks.append(AKMusicTrack(musicTrack: newMusicTrack, name: name))
        
        //print("Calling initTracks() from newTrack")
        //initTracks()
        return tracks.last!
    }
    
    /// Clear some events from the track
    public func clearRange(start: Beat, duration: Beat) {
        if isAVSequencer { return }

        for track in tracks {
            track.clearRange(start, duration: duration)
        }
    }
    
    /// Set the music player time directly
    ///
    /// - parameter time: Music time stamp to set
    ///
    public func setTime(time: MusicTimeStamp) {
        MusicPlayerSetTime(musicPlayer, time)
    }
    
    /// Generate NSData from the sequence
    public func genData() -> NSData? {
        var status = noErr
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
        if isAVSequencer {
            print("No debug information available for AVAudioEngine's sequencer.")
        } else {
            CAShow(sequencePointer)
        }
    }
    
    /// Calculates beats in to a file based on it samples, sample rate, and tempo
    ///
    /// - parameter samples:    Number of samples in
    /// - parameter sampleRate: Sample frequency
    /// - parameter tempo:      Tempo, in beats per minute
    ///
    public static func beatsFromSamples(samples: Int, sampleRate: Int, tempo: Double) -> Beat {
        let timeInSecs = Double(samples) / Double(sampleRate)
        let beatsPerSec = tempo / 60.0
        let beatLengthInSecs = Double(1.0 / beatsPerSec)
        return Beat(timeInSecs / beatLengthInSecs)
    }
}
