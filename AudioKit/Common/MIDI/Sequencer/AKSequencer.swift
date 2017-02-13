//
//  AKSequencer.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Basic sequencer
///
/// This  is currently in transistion from old c core audio apis, to the more
/// modern avaudiosequencer setup. However, the new system is not as advanced as the
/// old, so we will keep both and have them interact. In addition, some of the features
/// of the new AVAudioSequencer don't even work yet (midi sequencing).
/// Still, both have their strengths and weaknesses so I am keeping them both.
/// As such, there is some code hanging around while we iron it out.
///
open class AKSequencer {

    /// Music sequence
    open var sequence: MusicSequence?

    /// Pointer to Music Sequence
    open var sequencePointer: UnsafeMutablePointer<MusicSequence>

    /// AVAudioSequencer - on hold while technology is still unstable
    open var avSequencer = AVAudioSequencer()

    /// Array of AudioKit Music Tracks
    open var tracks = [AKMusicTrack]()

    /// Array of AVMusicTracks
    open var avTracks: [AVMusicTrack] {
        if isAVSequencer {
            return avSequencer.tracks
        } else {
            //this won't do anything if not using an AVSeq
            AKLog("AKSequencer ERROR ! avTracks only work if isAVSequencer ")

            let tracks = [AVMusicTrack]()
            return tracks
        }
    }

    /// Music Player
    var musicPlayer: MusicPlayer?

    /// Loop control
    open var loopEnabled: Bool = false

    /// Are we using the AVAudioEngineSequencer?
    open var isAVSequencer: Bool = false

    /// Sequencer Initialization
    public init() {
        NewMusicSequence(&sequence)
        sequencePointer = UnsafeMutablePointer<MusicSequence>(sequence!)

        //setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer!, sequence)
    }

    deinit {
        if let player = musicPlayer {
            DisposeMusicPlayer(player)
        }

        if let seq = sequence {
            for track in self.tracks {
                if let intTrack = track.internalMusicTrack {
                    MusicSequenceDisposeTrack(seq, intTrack)
                }
            }

            DisposeMusicSequence(seq)
        }
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
    open func sequenceFromData(_ data: Data) {
        let options = AVMusicSequenceLoadOptions()

        do {
            try avSequencer.load(from: data, options: options)
            AKLog("should have loaded new sequence data")
        } catch {
            AKLog("cannot load from data \(error)")
            return
        }
    }

    /// Preroll for the music player
    open func preroll() {
        MusicPlayerPreroll(musicPlayer!)
    }

    /// Set loop functionality of entire sequence
    open func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }

    /// Enable looping for all tracks - loops entire sequence
    open func enableLooping() {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.isLoopingEnabled = true
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
    open func enableLooping(_ loopLength: AKDuration) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.isLoopingEnabled = true
                track.loopRange = AVMakeBeatRange(0, self.length.beats)
            }
        } else {
            setLoopInfo(loopLength, numberOfLoops: 0)
        }
        loopEnabled = true
    }

    /// Disable looping for all tracks
    open func disableLooping() {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.isLoopingEnabled = false
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
    open func setLoopInfo(_ duration: AKDuration, numberOfLoops: Int) {
        if isAVSequencer {
            AKLog("AKSequencer ERROR ! setLoopInfo only work if not isAVSequencer ")

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
    open func setLength(_ length: AKDuration) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.lengthInBeats = length.beats
                track.loopRange = AVMakeBeatRange(0, length.beats)
            }
        } else {
            for track in tracks {
                track.setLength(length)
            }

            let size: UInt32 = 0
            var len = length.musicTimeStamp
            var tempoTrack: MusicTrack? = nil
            MusicSequenceGetTempoTrack(sequence!, &tempoTrack)
            MusicTrackSetProperty(tempoTrack!, kSequenceTrackProperty_TrackLength, &len, size)
        }
    }

    /// Length of longest track in the sequence
    open var length: AKDuration {

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
    open var rate: Double? {
        get {
            if isAVSequencer {
                return Double(avSequencer.rate)
            } else {
                AKLog("AKSequencer ERROR ! rate only work if isAVSequencer ")
                return nil
            }
        }
        set {
            if isAVSequencer {
                avSequencer.rate = Float(newValue!)
            } else {
                AKLog("AKSequencer ERROR ! rate only work if isAVSequencer ")
            }
        }
    }

    /// Set the tempo of the sequencer
    open func setTempo(_ bpm: Double) {
        if isAVSequencer {
            return
        }

        let constrainedTempo = (10...280).clamp(bpm)

        var tempoTrack: MusicTrack? = nil

        MusicSequenceGetTempoTrack(sequence!, &tempoTrack)
        if isPlaying {
            var currTime: MusicTimeStamp = 0
            MusicPlayerGetTime(musicPlayer!, &currTime)
            currTime = fmod(currTime, length.beats)
            MusicTrackNewExtendedTempoEvent(tempoTrack!, currTime, constrainedTempo)
        }

// Had to comment out this line and two below to make the synth arpeggiator work.  
// Doing so brings back the "Invalid beat range or track is empty" error
//        if !isTempoTrackEmpty {
        MusicTrackClear(tempoTrack!, 0, length.beats)
//        }
        MusicTrackNewExtendedTempoEvent(tempoTrack!, 0, constrainedTempo)
    }

    /// Add a  tempo change to the score
    ///
    /// - Parameters:
    ///   - bpm: Tempo in beats per minute
    ///   - position: Point in time in beats
    ///
    open func addTempoEventAt(tempo bpm: Double, position: AKDuration) {
        if isAVSequencer {
            AKLog("AKSequencer ERROR ! addTempoEventAt only work if not isAVSequencer ")
            return
        }

        let constrainedTempo = (10...280).clamp(bpm)

        var tempoTrack: MusicTrack? = nil

        MusicSequenceGetTempoTrack(sequence!, &tempoTrack)
        MusicTrackNewExtendedTempoEvent(tempoTrack!, position.beats, constrainedTempo)

    }

    /// Tempo retrieved from the sequencer
    open var tempo: Double {
        var tempoOut: Double = 120.0

        var tempoTrack: MusicTrack? = nil
        MusicSequenceGetTempoTrack(sequence!, &tempoTrack)

        var iterator: MusicEventIterator? = nil
        NewMusicEventIterator(tempoTrack!, &iterator)

        var eventTime: MusicTimeStamp = 0
        var eventType: MusicEventType = kMusicEventType_ExtendedTempo
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0

        var hasPreviousEvent: DarwinBoolean = false
        MusicEventIteratorSeek(iterator!, currentPosition.beats)
        MusicEventIteratorHasPreviousEvent(iterator!, &hasPreviousEvent)
        if hasPreviousEvent.boolValue {
            MusicEventIteratorPreviousEvent(iterator!)
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)
            if eventType == kMusicEventType_ExtendedTempo {
                let tempoEventPointer: UnsafePointer<ExtendedTempoEvent> = UnsafePointer(
                    (eventData?.assumingMemoryBound(to: ExtendedTempoEvent.self))!
                )
                tempoOut = tempoEventPointer.pointee.bpm
            }
        }

        return tempoOut
    }

    var isTempoTrackEmpty: Bool {
        var outBool = true
        var iterator: MusicEventIterator? = nil
        var tempoTrack: MusicTrack? = nil
        MusicSequenceGetTempoTrack(sequence!, &tempoTrack)
        NewMusicEventIterator(tempoTrack!, &iterator)
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator!, &eventTime, &eventType, &eventData, &eventDataSize)

            if eventType != 5 {
                outBool = true
            }
            MusicEventIteratorNextEvent(iterator!)
            MusicEventIteratorHasCurrentEvent(iterator!, &hasNextEvent)
        }
        return outBool
    }

    /// Convert seconds into AKDuration
    ///
    /// - parameter seconds: time in seconds
    ///
    open func duration(seconds: Double) -> AKDuration {
        let sign = seconds > 0 ? 1.0 : -1.0
        let absoluteValueSeconds = fabs(seconds)
        var outBeats = AKDuration(beats: MusicTimeStamp())
        MusicSequenceGetBeatsForSeconds(sequence!, Float64(absoluteValueSeconds), &(outBeats.beats))
        outBeats.beats *= sign
        return outBeats
    }

    /// Convert beats into seconds
    ///
    /// - parameter duration: AKDuration
    ///
    open func seconds(duration: AKDuration) -> Double {
        let sign = duration.beats > 0 ? 1.0 : -1.0
        let absoluteValueBeats = fabs(duration.beats)
        var outSecs: Double = MusicTimeStamp()
        MusicSequenceGetSecondsForBeats(sequence!, absoluteValueBeats, &outSecs)
        outSecs *= sign
        return outSecs
    }

    /// Play the sequence
    open func play() {
        if isAVSequencer {
            do {
                try avSequencer.start()
            } catch _ {
                AKLog("could not start avSeq")
            }
        } else {
            MusicPlayerStart(musicPlayer!)
        }
    }

    /// Stop the sequence
    open func stop() {
        if isAVSequencer {
            avSequencer.stop()
        } else {
            MusicPlayerStop(musicPlayer!)
        }
    }

    /// Rewind the sequence
    open func rewind() {
        if isAVSequencer {
            avSequencer.currentPositionInBeats = 0
        } else {
            MusicPlayerSetTime(musicPlayer!, 0)
        }
    }

    /// Set the Audio Unit output for all tracks - on hold while technology is still unstable
    open func setGlobalAVAudioUnitOutput(_ audioUnit: AVAudioUnit) {
        if isAVSequencer {
            for track in avSequencer.tracks {
                track.destinationAudioUnit = audioUnit
            }
        } else {
            //do nothing - doesn't apply. In the old C-api, MusicTracks could point at AUNodes, but we don't use those
            AKLog("AKSequencer ERROR ! setGlobalAVAudioUnitOutput only work if isAVSequencer ")
        }
    }

    /// Wheter or not the sequencer is currently playing
    open var isPlaying: Bool {
        if isAVSequencer {
            return avSequencer.isPlaying
        } else {
            var isPlayingBool: DarwinBoolean = false
            MusicPlayerIsPlaying(musicPlayer!, &isPlayingBool)
            return isPlayingBool.boolValue
        }
    }

    /// Current Time
    open var currentPosition: AKDuration {
        if isAVSequencer {
            return AKDuration(beats: avSequencer.currentPositionInBeats)
        } else {
            var currentTime = MusicTimeStamp()
            MusicPlayerGetTime(musicPlayer!, &currentTime)
            let duration = AKDuration(beats: currentTime)
            return duration
        }
    }
    /// Current Time relative to sequencer length
    open var currentRelativePosition: AKDuration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Track count
    open var trackCount: Int {
        if isAVSequencer {
            return avSequencer.tracks.count
        } else {
            var count: UInt32 = 0
            MusicSequenceGetTrackCount(sequence!, &count)
            return Int(count)
        }
    }

    /// Load a MIDI file
    open func loadMIDIFile(_ filename: String) {
        let bundle = Bundle.main
        let file = bundle.path(forResource: filename, ofType: "mid")
        let fileURL = URL(fileURLWithPath: file!)
        MusicSequenceFileLoad(sequence!, fileURL as CFURL, .midiType, MusicSequenceLoadFlags())
        if isAVSequencer {
            do {
                try avSequencer.load(from: fileURL, options: AVMusicSequenceLoadOptions())
            } catch _ {
                AKLog("failed to load midi into avseq")
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
        MusicSequenceGetTrackCount(sequence!, &count)

        for i in 0 ..< count {
            var musicTrack: MusicTrack? = nil
            MusicSequenceGetIndTrack(sequence!, UInt32(i), &musicTrack)
            tracks.append(AKMusicTrack(musicTrack: musicTrack!, name: "InitializedTrack"))
        }
    }

    /// Get a new track
    open func newTrack(_ name: String = "Unnamed") -> AKMusicTrack? {
        if isAVSequencer {
            AKLog("AKSequencer ERROR ! newTrack only work if not isAVSequencer ")
            return nil
        }

        var newMusicTrack: MusicTrack? = nil
        MusicSequenceNewTrack(sequence!, &newMusicTrack)
        var count: UInt32 = 0
        MusicSequenceGetTrackCount(sequence!, &count)
        tracks.append(AKMusicTrack(musicTrack: newMusicTrack!, name: name))

        //AKLog("Calling initTracks() from newTrack")
        //initTracks()
        return tracks.last!
    }

    /// Clear some events from the track
    //
    /// - Parameters:
    ///   - start:    Starting position of clearing
    ///   - duration: Length of time after the start position to clear
    ///
    open func clearRange(start: AKDuration, duration: AKDuration) {
        if isAVSequencer {
            AKLog("AKSequencer ERROR ! clearRange only work if not isAVSequencer ")
            return
        }

        for track in tracks {
            track.clearRange(start: start, duration: duration)
        }
    }

    /// Set the music player time directly
    ///
    /// - parameter time: Music time stamp to set
    ///
    open func setTime(_ time: MusicTimeStamp) {
        MusicPlayerSetTime(musicPlayer!, time)
    }

    /// Generate NSData from the sequence
    open func genData() -> Data? {
        var status = noErr
        var data: Unmanaged<CFData>?
        status = MusicSequenceFileCreateData(sequence!, .midiType, .eraseFile, 480, &data)
        if status != noErr {
            AKLog("error creating MusicSequence Data")
            return nil
        }
        let ns: Data = data!.takeUnretainedValue() as Data
        data?.release()
        return ns
    }

    /// Print sequence to console
    open func debug() {
        if isAVSequencer {
            AKLog("No debug information available for AVAudioEngine's sequencer.")
        } else {
            CAShow(sequencePointer)
        }
    }

    /// Set the midi output for all tracks
    open func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
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

    /// Nearest time of quantized beat
    open func nearestQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        let noteOnTimeRel = currentRelativePosition.beats
        let quantizationPositions = getQuantizationPositions(quantizationInBeats: quantizationInBeats)
        let lastSpot = quantizationPositions[0]
        let nextSpot = quantizationPositions[1]
        let diffToLastSpot = AKDuration(beats: noteOnTimeRel) - lastSpot
        let diffToNextSpot = nextSpot - AKDuration(beats: noteOnTimeRel)
        let optimisedQuantTime = (diffToLastSpot < diffToNextSpot ? lastSpot : nextSpot)
        //AKLog("last \(lastSpot.beats) - curr \(currentRelativePosition.beats) - next \(nextSpot.beats)")
        //AKLog("nearest \(optimisedQuantTime.beats)")
        return optimisedQuantTime
    }

    /// The last quantized beat
    open func previousQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[0]
    }

    /// Next quantized beat
    open func nextQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[1]
    }

    /// An array of all quantization points
    func getQuantizationPositions(quantizationInBeats: Double) -> [AKDuration] {
        let noteOnTimeRel = currentRelativePosition.beats
        let lastSpot = AKDuration(beats:
            modTime(noteOnTimeRel - (noteOnTimeRel.truncatingRemainder(dividingBy: quantizationInBeats))))
        let nextSpot = AKDuration(beats: modTime(lastSpot.beats + quantizationInBeats))
        return [lastSpot, nextSpot]
    }

    /// Time modulus
    func modTime(_ time: Double) -> Double {
        return time.truncatingRemainder(dividingBy: length.beats)
    }
}
