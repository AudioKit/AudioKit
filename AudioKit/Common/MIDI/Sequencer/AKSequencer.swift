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

    /// Initialize the sequence with a midi file and audioengine - on hold while technology is still unstable
    ///
    /// - Parameters:
    ///   - filename: Location of the MIDI File
    ///   - engine: reference to the AV Audio Engine
    ///
    public convenience init(filename: String, engine: AVAudioEngine) {
        self.init()
        isAVSequencer = true
        avSequencer = AVAudioSequencer(audioEngine: engine)
        loadMIDIFile(filename)
    }

    /// Initialize the sequence with an empty sequence and audioengine
    /// (on hold while technology is still unstable)
    ///
    /// - parameter engine: reference to the AV Audio Engine
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
                track.loopRange = AVMakeBeatRange(0, self.length.beats)
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
    public func enableLooping(loopLength: AKDuration) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.loopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length.beats)
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
            setLoopInfo(AKDuration(beats: 0), numberOfLoops: 0)
        }
        loopEnabled = false
    }

    /// Set looping duration and count for all tracks
    ///
    /// - Parameters:
    ///   - duration: Duration of the loop in beats
    ///   - numberOfLoops: The number of time to repeat
    ///
    public func setLoopInfo(duration: AKDuration, numberOfLoops: Int) {
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
    public func setLength(length: AKDuration) {
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
                track.lengthInBeats = length.beats
                track.loopRange = AVMakeBeatRange(0, length.beats)
            }
        }
    }

    /// Length of longest track in the sequence
    public var length: AKDuration {

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
        return  AKDuration(beats: length, tempo: tempo)
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

        let constrainedTempo = min(max(bpm, 10.0), 280.0)

        var tempoTrack: MusicTrack = nil

        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if isPlaying {
            var currTime: MusicTimeStamp = 0
            MusicPlayerGetTime(musicPlayer, &currTime)
            currTime = fmod(currTime, length.beats)
            MusicTrackNewExtendedTempoEvent(tempoTrack, currTime, constrainedTempo)
        }
        if !isTempoTrackEmpty {
            MusicTrackClear(tempoTrack, 0, length.beats)
        }
        MusicTrackNewExtendedTempoEvent(tempoTrack, 0, constrainedTempo)
    }

    /// Add a  tempo change to the score
    ///
    /// - Parameters:
    ///   - bpm: Tempo in beats per minute
    ///   - position: Point in time in beats
    ///
    public func addTempoEventAt(tempo bpm: Double, position: AKDuration) {
        if isAVSequencer { return }

        let constrainedTempo = min(max(bpm, 10.0), 280.0)

        var tempoTrack: MusicTrack = nil

        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        MusicTrackNewExtendedTempoEvent(tempoTrack, position.beats, constrainedTempo)

    }
    
    /// Tempo retrieved from the sequencer
    public var tempo: Double {
        var tempoOut: Double = 120.0
        
        var tempoTrack: MusicTrack = nil
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        
        var iterator:MusicEventIterator = nil
        NewMusicEventIterator(tempoTrack, &iterator);
        
        var eventTime: MusicTimeStamp = 0
        var eventType: MusicEventType = kMusicEventType_ExtendedTempo
        var eventData: UnsafePointer<Void> = nil
        var eventDataSize: UInt32 = 0
        
        var hasPreviousEvent: DarwinBoolean = false
        MusicEventIteratorSeek(iterator, currentPosition.beats)
        MusicEventIteratorHasPreviousEvent(iterator, &hasPreviousEvent)
        if hasPreviousEvent {
            MusicEventIteratorPreviousEvent(iterator)
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize);
            if eventType == kMusicEventType_ExtendedTempo {
                let tempoEventPointer: UnsafePointer<ExtendedTempoEvent> = UnsafePointer(eventData)
                tempoOut = tempoEventPointer.memory.bpm
            }
        }

        return tempoOut
    }
    
    var isTempoTrackEmpty : Bool {
        var outBool = true
        var iterator: MusicEventIterator = nil
        var tempoTrack: MusicTrack = nil
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        NewMusicEventIterator(tempoTrack, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafePointer<Void> = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false
        
        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        while(hasNextEvent) {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)
            
            if eventType != 5 {
                outBool = true
            }
            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }
        return outBool
    }
    
    /// Convert seconds into AKDuration
    ///
    /// - parameter seconds: time in seconds
    ///
    public func duration(seconds seconds: Double) -> AKDuration {
        let sign = seconds > 0 ? 1.0 : -1.0
        let absoluteValueSeconds = fabs(seconds)
        var outBeats = AKDuration(beats: MusicTimeStamp())
        MusicSequenceGetBeatsForSeconds(sequence, Float64(absoluteValueSeconds), &(outBeats.beats))
        outBeats.beats = outBeats.beats * sign
        return outBeats
    }

    /// Convert beats into seconds
    ///
    /// - parameter duration: AKDuration
    ///
    public func seconds(duration duration: AKDuration) -> Double {
        let sign = duration.beats > 0 ? 1.0 : -1.0
        let absoluteValueBeats = fabs(duration.beats)
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
    public var currentPosition: AKDuration {
        if isAVSequencer {
            return AKDuration(beats: avSequencer.currentPositionInBeats)
        } else {
            var currentTime = MusicTimeStamp()
            MusicPlayerGetTime(musicPlayer, &currentTime)
            let duration = AKDuration(beats: currentTime)
            return duration
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
    //
    /// - Parameters:
    ///   - start:    Starting position of clearing
    ///   - duration: Length of time after the start position to clear
    ///
    public func clearRange(start start: AKDuration, duration: AKDuration) {
        if isAVSequencer { return }

        for track in tracks {
            track.clearRange(start: start, duration: duration)
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
    
    /// Set the midi output for all tracks
    public func setGlobalMIDIOutput(midiEndpoint: MIDIEndpointRef) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.destinationMIDIEndpoint = midiEndpoint
            }
        } else {
            for track in tracks {
                track.setMIDIOutput(midiEndpoint)
            }
        }
    }
}
