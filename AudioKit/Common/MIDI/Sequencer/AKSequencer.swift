//
//  AKMusicSequencer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Sequencer based on tried-and-true CoreAudio/MIDI Sequencing
open class AKSequencer {

    /// Music sequence
    open var sequence: MusicSequence?

    /// Pointer to Music Sequence
    open var sequencePointer: UnsafeMutablePointer<MusicSequence>?

    /// Array of AudioKit Music Tracks
    open var tracks = [AKMusicTrack]()

    /// Music Player
    var musicPlayer: MusicPlayer?

    /// Loop control
    open private(set) var loopEnabled: Bool = false

    /// Sequencer Initialization
    @objc public init() {
        NewMusicSequence(&sequence)
        if let existingSequence = sequence {
            sequencePointer = UnsafeMutablePointer<MusicSequence>(existingSequence)
        }
        //setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetSequence(existingMusicPlayer, sequence)
        }
    }

    deinit {
        AKLog("deinit:")

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

    /// Initialize the sequence with a MIDI file
    ///
    /// - parameter fromURL: URL of MIDI File
    ///
    public convenience init(fromURL fileURL: URL) {
        self.init()
        loadMIDIFile(fromURL: fileURL)
    }

    /// Preroll the music player. Call this function in advance of playback to reduce the sequencers 
    /// startup latency. If you call `play` without first calling this function, the sequencer will 
    /// call this function before beginning playback.
    open func preroll() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerPreroll(existingMusicPlayer)
        }
    }

    /// Set loop functionality of entire sequence
    open func toggleLoop() {
        (loopEnabled ? disableLooping() : enableLooping())
    }

    /// Enable looping for all tracks - loops entire sequence
    open func enableLooping() {
        setLoopInfo(length, numberOfLoops: 0)
        loopEnabled = true
    }

    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    open func enableLooping(_ loopLength: AKDuration) {
        setLoopInfo(loopLength, numberOfLoops: 0)
        loopEnabled = true
    }

    /// Disable looping for all tracks
    open func disableLooping() {
        setLoopInfo(AKDuration(beats: 0), numberOfLoops: 0)
        loopEnabled = false
    }

    /// Set looping duration and count for all tracks
    ///
    /// - Parameters:
    ///   - duration: Duration of the loop in beats
    ///   - numberOfLoops: The number of time to repeat
    ///
    open func setLoopInfo(_ duration: AKDuration, numberOfLoops: Int) {
        for track in tracks {
            track.setLoopInfo(duration, numberOfLoops: numberOfLoops)
        }
        loopEnabled = true
    }

    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    open func setLength(_ length: AKDuration) {
        for track in tracks {
            track.setLength(length)
        }
        let size: UInt32 = 0
        var len = length.musicTimeStamp
        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }
        if let existingTempoTrack = tempoTrack {
            MusicTrackSetProperty(existingTempoTrack, kSequenceTrackProperty_TrackLength, &len, size)
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

        return  AKDuration(beats: length, tempo: tempo)
    }

    /// Set the rate of the sequencer
    ///
    /// - parameter rate: Set the rate relative to the tempo of the track
    ///
    open func setRate(_ rate: Double) {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetPlayRateScalar(existingMusicPlayer, MusicTimeStamp(rate))
        }
    }

    /// Rate relative to the default tempo (BPM) of the track
    open var rate: Double {
        var rate = MusicTimeStamp(1.0)
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerGetPlayRateScalar(existingMusicPlayer, &rate)
        }
        return rate
    }

    /// Set the tempo of the sequencer
    open func setTempo(_ bpm: Double) {
        let constrainedTempo = (10...280).clamp(bpm)

        var tempoTrack: MusicTrack?

        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }
        if isPlaying {
            var currTime: MusicTimeStamp = 0
            if let existingMusicPlayer = musicPlayer {
                MusicPlayerGetTime(existingMusicPlayer, &currTime)
            }
            currTime = fmod(currTime, length.beats)
            if let existingTempoTrack = tempoTrack {
                MusicTrackNewExtendedTempoEvent(existingTempoTrack, currTime, constrainedTempo)

            }
        }
        if let existingTempoTrack = tempoTrack {
            MusicTrackClear(existingTempoTrack, 0, length.beats)
            MusicTrackNewExtendedTempoEvent(existingTempoTrack, 0, constrainedTempo)
        }
    }

    /// Add a  tempo change to the score
    ///
    /// - Parameters:
    ///   - bpm: Tempo in beats per minute
    ///   - position: Point in time in beats
    ///
    open func addTempoEventAt(tempo bpm: Double, position: AKDuration) {
        let constrainedTempo = (10...280).clamp(bpm)

        var tempoTrack: MusicTrack?

        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }
        if let existingTempoTrack = tempoTrack {
            MusicTrackNewExtendedTempoEvent(existingTempoTrack, position.beats, constrainedTempo)
        }
    }

    /// Tempo retrieved from the sequencer
    open var tempo: Double {
        var tempoOut: Double = 120.0

        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        var tempIterator: MusicEventIterator?
        if let existingTempoTrack = tempoTrack {
            NewMusicEventIterator(existingTempoTrack, &tempIterator)
        }
        guard let iterator = tempIterator else {
            return 0.0
        }

        var eventTime: MusicTimeStamp = 0
        var eventType: MusicEventType = kMusicEventType_ExtendedTempo
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0

        var hasPreviousEvent: DarwinBoolean = false
        MusicEventIteratorSeek(iterator, currentPosition.beats)
        MusicEventIteratorHasPreviousEvent(iterator, &hasPreviousEvent)
        if hasPreviousEvent.boolValue {
            MusicEventIteratorPreviousEvent(iterator)
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)
            if eventType == kMusicEventType_ExtendedTempo {
                if let data = eventData?.assumingMemoryBound(to: ExtendedTempoEvent.self) {
                    let tempoEventPointer: UnsafePointer<ExtendedTempoEvent> = UnsafePointer(data)
                    tempoOut = tempoEventPointer.pointee.bpm
                }
            }
        }
        DisposeMusicEventIterator(iterator)
        return tempoOut
    }

    var isTempoTrackEmpty: Bool {
        var outBool = true
        var tempIterator: MusicEventIterator?
        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        if let existingTempoTrack = tempoTrack {
            NewMusicEventIterator(existingTempoTrack, &tempIterator)
        }
        guard let iterator = tempIterator else {
            return true
        }

        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)

            if eventType != 5 {
                outBool = true
            }
            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }
        DisposeMusicEventIterator(iterator)
        return outBool
    }

    /// Possible values for the time signature lower value
    public enum TimeSignatureBottomValue: UInt8 {
        // According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case two = 1
        case four = 2
        case eight = 3
        case sixteen = 4
    }

    /// Add a time signature event to start of tempo track
    /// NB: will affect MIDI file layout but NOT sequencer playback
    ///
    /// - Parameters:
    ///   - timeSignatureTop: Number of beats per measure
    ///   - timeSignatureBottom: Unit of beat
    ///
    open func addTimeSignatureEvent(timeSignatureTop: UInt8, timeSignatureBottom: TimeSignatureBottomValue) {
        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        if let tempoTrack = tempoTrack {
            clearTimeSignatureEvents(tempoTrack)
        }

        let ticksPerMetronomeClick: UInt8 = 24
        let thirtySecondNotesPerQuarter: UInt8 = 8
        let data: [MIDIByte] = [timeSignatureTop,
                                timeSignatureBottom.rawValue,
                                ticksPerMetronomeClick,
                                thirtySecondNotesPerQuarter]

        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 0x58 // i.e, set time signature
        metaEvent.dataLength = UInt32(data.count)

        withUnsafeMutablePointer(to: &metaEvent.data, { pointer in
            for i in 0 ..< data.count {
                pointer[i] = data[i]
            }
        })

        let result = MusicTrackNewMetaEvent(tempoTrack!, MusicTimeStamp(0), &metaEvent)
        if result != 0 {
            AKLog("Unable to set time signature")
        }
    }

    /// Remove existing time signature events from tempo track
    func clearTimeSignatureEvents(_ track: MusicTrack) {
        let timeSignatureMetaEventByte: UInt8 = 0x58
        let metaEventType = kMusicEventType_Meta

        AKMusicTrack.iterateMusicTrack(track) {iterator, _, eventType, eventData, _ in
            guard eventType == metaEventType else { return }

            let data = UnsafePointer<MIDIMetaEvent>(eventData?.assumingMemoryBound(to: MIDIMetaEvent.self))
            guard let  dataMetaEventType = data?.pointee.metaEventType else { return }

            if dataMetaEventType == timeSignatureMetaEventByte {
                MusicEventIteratorDeleteEvent(iterator)
            }
        }
    }

    /// Convert seconds into AKDuration
    ///
    /// - parameter seconds: time in seconds
    ///
    open func duration(seconds: Double) -> AKDuration {
        let sign = seconds > 0 ? 1.0 : -1.0
        let absoluteValueSeconds = fabs(seconds)
        var outBeats = AKDuration(beats: MusicTimeStamp())
        if let existingSequence = sequence {
            MusicSequenceGetBeatsForSeconds(existingSequence, Float64(absoluteValueSeconds), &(outBeats.beats))
        }
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
        if let existingSequence = sequence {
            MusicSequenceGetSecondsForBeats(existingSequence, absoluteValueBeats, &outSecs)
        }
        outSecs *= sign
        return outSecs
    }

    /// Play the sequence
    open func play() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerStart(existingMusicPlayer)
        }
    }

    /// Stop the sequence
    @objc open func stop() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerStop(existingMusicPlayer)
        }
    }

    /// Rewind the sequence
    open func rewind() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetTime(existingMusicPlayer, 0)
        }
    }

    /// Wheter or not the sequencer is currently playing
    open var isPlaying: Bool {
        var isPlayingBool: DarwinBoolean = false
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerIsPlaying(existingMusicPlayer, &isPlayingBool)
        }
        return isPlayingBool.boolValue
    }

    /// Current Time
    open var currentPosition: AKDuration {
        var currentTime = MusicTimeStamp()
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerGetTime(existingMusicPlayer, &currentTime)
        }
        let duration = AKDuration(beats: currentTime)
        return duration
    }

    /// Current Time relative to sequencer length
    open var currentRelativePosition: AKDuration {
        return currentPosition % length //can switch to modTime func when/if % is removed
    }

    /// Track count
    open var trackCount: Int {
        var count: UInt32 = 0
        if let existingSequence = sequence {
            MusicSequenceGetTrackCount(existingSequence, &count)
        }
        return Int(count)
    }

    /// Load a MIDI file from the bundle (removes old tracks, if present)
    open func loadMIDIFile(_ filename: String) {
        let bundle = Bundle.main
        guard let file = bundle.path(forResource: filename, ofType: "mid") else {
            AKLog("No midi file found")
            return
        }
        let fileURL = URL(fileURLWithPath: file)
        loadMIDIFile(fromURL: fileURL)
    }

    /// Load a MIDI file given a URL (removes old tracks, if present)
    open func loadMIDIFile(fromURL fileURL: URL) {
        removeTracks()
        if let existingSequence = sequence {
            let status: OSStatus = MusicSequenceFileLoad(existingSequence, fileURL as CFURL, .midiType, MusicSequenceLoadFlags())
            if status != OSStatus(noErr) {
                AKLog("error reading midi file url: \(fileURL), read status: \(status)")
            }
        }
        initTracks()
    }

    // MARK: Adding MIDI File data to current sequencer

    /// Add tracks from MIDI file to existing sequencer
    ///
    /// - Parameters:
    ///   - filename: Location of the MIDI File
    ///   - useExistingSequencerLength: flag for automatically setting length of new track to current sequence length
    ///
    ///  Will copy only MIDINoteMessage events
    open func addMIDIFileTracks(_ filename: String, useExistingSequencerLength: Bool = true) {
        let tempSequencer = AKSequencer(filename: filename)
        addMusicTrackNoteData(from: tempSequencer, useExistingSequencerLength: useExistingSequencerLength)
    }

    /// Add tracks from MIDI file to existing sequencer
    ///
    /// - Parameters:
    ///   - filename: fromURL: URL of MIDI File
    ///   - useExistingSequencerLength: flag for automatically setting length of new track to current sequence length
    ///
    ///  Will copy only MIDINoteMessage events
    open func addMIDIFileTracks(_ url: URL, useExistingSequencerLength: Bool = true) {
        let tempSequencer = AKSequencer(fromURL: url)
        addMusicTrackNoteData(from: tempSequencer, useExistingSequencerLength: useExistingSequencerLength)
    }

    /// Creates new AKMusicTrack with copied note event data from another AKSequencer
    func addMusicTrackNoteData(from tempSequencer: AKSequencer, useExistingSequencerLength: Bool) {
        guard !isPlaying else {
            AKLog("Can't add tracks during playback")
            return }

        let oldLength = self.length
        for track in tempSequencer.tracks {
            let noteData = track.getMIDINoteData()

            if noteData.isEmpty { continue }
            let addedTrack = newTrack()

            addedTrack?.replaceMIDINoteData(with: noteData)

            if useExistingSequencerLength {
                addedTrack?.setLength(oldLength)
            }
        }

        if loopEnabled {
            enableLooping()
        }
    }

    /// Initialize all tracks
    ///
    /// Rebuilds tracks based on actual contents of music sequence
    ///
    func initTracks() {
        var count: UInt32 = 0
        if let existingSequence = sequence {
            MusicSequenceGetTrackCount(existingSequence, &count)
        }

        for i in 0 ..< count {
            var musicTrack: MusicTrack?
            if let existingSequence = sequence {
                MusicSequenceGetIndTrack(existingSequence, UInt32(i), &musicTrack)
            }
            if let existingMusicTrack = musicTrack {
                tracks.append(AKMusicTrack(musicTrack: existingMusicTrack, name: "InitializedTrack"))
            }
        }

        if loopEnabled {
            enableLooping()
        }
    }

    ///  Dispose of tracks associated with sequence
    func removeTracks() {
        if let existingSequence = sequence {
            var tempoTrack: MusicTrack?
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
            if let track = tempoTrack {
                MusicTrackClear(track, 0, length.musicTimeStamp)
            }

            for track in tracks {
                if let internalTrack = track.internalMusicTrack {
                    MusicSequenceDisposeTrack(existingSequence, internalTrack)
                }
            }
        }
        tracks.removeAll()
    }

    /// Get a new track
    open func newTrack(_ name: String = "Unnamed") -> AKMusicTrack? {

        var newMusicTrack: MusicTrack?
        var count: UInt32 = 0
        if let existingSequence = sequence {
            MusicSequenceNewTrack(existingSequence, &newMusicTrack)
            MusicSequenceGetTrackCount(existingSequence, &count)
        }
        if let existingNewMusicTrack = newMusicTrack {
            tracks.append(AKMusicTrack(musicTrack: existingNewMusicTrack, name: name))
        }

        //AKLog("Calling initTracks() from newTrack")
        //initTracks()
        return tracks.last
    }

    /// Delete track and remove it from the sequence
    /// Not to be used during playback
    open func deleteTrack(trackIndex: Int) {
        guard !isPlaying else {
            AKLog("Can't delete sequencer track during playback")
            return }
        guard trackIndex < tracks.count,
            let internalTrack = tracks[trackIndex].internalMusicTrack else {
                AKLog("Can't get track for index")
                return
        }

        guard let existingSequence = sequence else {
            AKLog("Can't get sequence")
            return
        }

        MusicSequenceDisposeTrack(existingSequence, internalTrack)
        tracks.remove(at: trackIndex)
    }

    /// Clear all events from all tracks within the specified range
    //
    /// - Parameters:
    ///   - start: Start of the range to clear, in beats (inclusive)
    ///   - duration: Length of time after the start position to clear, in beats (exclusive)
    ///
    open func clearRange(start: AKDuration, duration: AKDuration) {
        for track in tracks {
            track.clearRange(start: start, duration: duration)
        }
    }

    /// Set the music player time directly
    ///
    /// - parameter time: Music time stamp to set
    ///
    open func setTime(_ time: MusicTimeStamp) {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetTime(existingMusicPlayer, time)
        }
    }

    /// Generate NSData from the sequence
    open func genData() -> Data? {
        var status = noErr
        var ns: Data = Data()
        var data: Unmanaged<CFData>?
        if let existingSequence = sequence {
            status = MusicSequenceFileCreateData(existingSequence, .midiType, .eraseFile, 480, &data)

            if status != noErr {
                AKLog("error creating MusicSequence Data")
                return nil
            }
        }
        if let existingData = data {
            ns = existingData.takeUnretainedValue() as Data
        }
        data?.release()
        return ns
    }

    /// Print sequence to console
    open func debug() {
        if let existingPointer = sequencePointer {
            CAShow(existingPointer)
        }
    }

    /// Set the midi output for all tracks
    open func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in tracks {
            track.setMIDIOutput(midiEndpoint)
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
