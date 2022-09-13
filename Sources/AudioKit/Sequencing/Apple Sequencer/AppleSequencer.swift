// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Sequencer based on tried-and-true CoreAudio/MIDI Sequencing
open class AppleSequencer: NSObject {
    /// Music sequence
    open var sequence: MusicSequence?

    /// Pointer to Music Sequence
    open var sequencePointer: UnsafeMutablePointer<MusicSequence>?

    /// Array of AudioKit Music Tracks
    open var tracks = [MusicTrackManager]()

    /// Music Player
    var musicPlayer: MusicPlayer?

    /// Loop control
    open private(set) var loopEnabled: Bool = false

    /// Sequencer Initialization
    override public init() {
        NewMusicSequence(&sequence)
        if let existingSequence = sequence {
            sequencePointer = UnsafeMutablePointer<MusicSequence>(existingSequence)
        }
        // setup and attach to musicplayer
        NewMusicPlayer(&musicPlayer)
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetSequence(existingMusicPlayer, sequence)
        }
    }

    deinit {
        Log("deinit:")

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
    /// - Parameter fileURL: URL of MIDI File
    public convenience init(fromURL fileURL: URL) {
        self.init()
        loadMIDIFile(fromURL: fileURL)
    }

    /// Initialize the sequence with a MIDI file data representation
    ///
    /// - parameter fromData: Data representation of a MIDI file
    ///
    public convenience init(fromData data: Data) {
        self.init()
        loadMIDIFile(fromData: data)
    }

    /// Preroll the music player. Call this function in advance of playback to reduce the sequencers
    /// startup latency. If you call `play` without first calling this function, the sequencer will
    /// call this function before beginning playback.
    public func preroll() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerPreroll(existingMusicPlayer)
        }
    }

    // MARK: - Looping

    /// Set loop functionality of entire sequence
    public func toggleLoop() {
        loopEnabled ? disableLooping() : enableLooping()
    }

    /// Enable looping for all tracks - loops entire sequence
    public func enableLooping() {
        setLoopInfo(length, loopCount: 0)
        loopEnabled = true
    }

    /// Enable looping for all tracks with specified length
    ///
    /// - parameter loopLength: Loop length in beats
    ///
    public func enableLooping(_ loopLength: Duration) {
        setLoopInfo(loopLength, loopCount: 0)
        loopEnabled = true
    }

    /// Disable looping for all tracks
    public func disableLooping() {
        setLoopInfo(Duration(beats: 0), loopCount: 0)
        loopEnabled = false
    }

    /// Set looping duration and count for all tracks
    ///
    /// - Parameters:
    ///   - duration: Duration of the loop in beats
    ///   - loopCount: The number of time to repeat
    ///
    public func setLoopInfo(_ duration: Duration, loopCount: Int) {
        for track in tracks {
            track.setLoopInfo(duration, loopCount: loopCount)
        }
        loopEnabled = true
    }

    // MARK: - Length

    /// Set length of all tracks
    ///
    /// - parameter length: Length of tracks in beats
    ///
    public func setLength(_ length: Duration) {
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
    open var length: Duration {
        var length: MusicTimeStamp = 0
        var tmpLength: MusicTimeStamp = 0

        for track in tracks {
            tmpLength = track.length
            if tmpLength >= length { length = tmpLength }
        }

        return Duration(beats: length, tempo: tempo)
    }

    // MARK: - Tempo and Rate

    /// Set the rate of the sequencer
    ///
    /// - parameter rate: Set the rate relative to the tempo of the track
    ///
    public func setRate(_ rate: Double) {
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

    /// Clears all existing tempo events and adds single tempo event at start
    /// Will also adjust the tempo immediately if sequence is playing when called
    public func setTempo(_ bpm: Double) {
        let constrainedTempo = max(1, bpm)

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
            clearTempoEvents(existingTempoTrack)
            MusicTrackNewExtendedTempoEvent(existingTempoTrack, 0, constrainedTempo)
        }
    }

    /// Add a  tempo change to the score
    ///
    /// - Parameters:
    ///   - bpm: Tempo in beats per minute
    ///   - position: Point in time in beats
    ///
    public func addTempoEventAt(tempo bpm: Double, position: Duration) {
        let constrainedTempo = max(1, bpm)

        var tempoTrack: MusicTrack?

        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }
        if let existingTempoTrack = tempoTrack {
            MusicTrackNewExtendedTempoEvent(existingTempoTrack, position.beats, constrainedTempo)
        }
    }

    /// Tempo retrieved from the sequencer. Defaults to 120
    /// NB: It looks at the currentPosition back in time for the last tempo event.
    /// If the sequence is not started, it returns default 120
    /// A sequence may contain several tempo events.
    open var tempo: Double {
        var tempoOut = 120.0

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
                if let data = eventData?.bindMemory(to: ExtendedTempoEvent.self, capacity: 1) {
                    tempoOut = data.pointee.bpm
                }
            }
        }
        DisposeMusicEventIterator(iterator)
        return tempoOut
    }

    /// returns an array of (MusicTimeStamp, bpm) tuples
    /// for all tempo events on the tempo track
    open var allTempoEvents: [(MusicTimeStamp, Double)] {
        var tempoTrack: MusicTrack?
        guard let existingSequence = sequence else { return [] }
        MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)

        var tempos = [(MusicTimeStamp, Double)]()

        if let tempoTrack = tempoTrack {
            MusicTrackManager.iterateMusicTrack(tempoTrack) { _, eventTime, eventType, eventData, _, _ in
                if eventType == kMusicEventType_ExtendedTempo {
                    if let data = eventData?.bindMemory(to: ExtendedTempoEvent.self, capacity: 1) {
                        tempos.append((eventTime, data.pointee.bpm))
                    }
                }
            }
        }
        return tempos
    }

    /// returns the tempo at a given position in beats
    /// - parameter at: Position at which the tempo is desired
    ///
    /// if there is more than one event precisely at the requested position
    /// it will return the most recently added
    /// Will return default 120 if there is no tempo event at or before position
    public func getTempo(at position: MusicTimeStamp) -> Double {
        // MIDI file with no tempo events defaults to 120 bpm
        var tempoAtPosition = 120.0
        for event in allTempoEvents {
            if event.0 <= position {
                tempoAtPosition = event.1
            } else {
                break
            }
        }

        return tempoAtPosition
    }

    // Remove existing tempo events
    func clearTempoEvents(_ track: MusicTrack) {
        MusicTrackManager.iterateMusicTrack(track) { iterator, _, eventType, _, _, isReadyForNextEvent in
            isReadyForNextEvent = true
            if eventType == kMusicEventType_ExtendedTempo {
                MusicEventIteratorDeleteEvent(iterator)
                isReadyForNextEvent = false
            }
        }
    }

    // MARK: - Time Signature

    /// Return and array of (MusicTimeStamp, TimeSignature) tuples
    open var allTimeSignatureEvents: [(MusicTimeStamp, TimeSignature)] {
        var tempoTrack: MusicTrack?
        var result = [(MusicTimeStamp, TimeSignature)]()

        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        guard let unwrappedTempoTrack = tempoTrack else {
            Log("Couldn't get tempo track")
            return result
        }

        let timeSignatureMetaEventByte: MIDIByte = 0x58
        MusicTrackManager.iterateMusicTrack(unwrappedTempoTrack) { _, eventTime, eventType, eventData, dataSize, _ in
            guard let eventData = eventData else { return }
            guard eventType == kMusicEventType_Meta else { return }

            let metaEventPointer = UnsafeMIDIMetaEventPointer(eventData)
            let metaEvent = metaEventPointer.event.pointee
            if metaEvent.metaEventType == timeSignatureMetaEventByte {
                let rawTimeSig = metaEventPointer.payload
                guard let bottomValue = TimeSignature.TimeSignatureBottomValue(rawValue: rawTimeSig[1]) else {
                    Log("Invalid time signature bottom value")
                    return
                }
                let timeSigEvent = TimeSignature(topValue: rawTimeSig[0],
                                                 bottomValue: bottomValue)
                result.append((eventTime, timeSigEvent))
            }
        }

        return result
    }

    /// returns the time signature at a given position in beats
    /// - parameter at: Position at which the time signature is desired
    ///
    /// If there is more than one event precisely at the requested position
    /// it will return the most recently added.
    /// Will return 4/4 if there is no Time Signature event at or before position
    public func getTimeSignature(at position: MusicTimeStamp) -> TimeSignature {
        var outTimeSignature = TimeSignature() // 4/4, by default
        for event in allTimeSignatureEvents {
            if event.0 <= position {
                outTimeSignature = event.1
            } else {
                break
            }
        }

        return outTimeSignature
    }

    /// Add a time signature event to start of tempo track
    /// NB: will affect MIDI file layout but NOT sequencer playback
    ///
    /// - Parameters:
    ///   - at: MusicTimeStamp where time signature event will be placed
    ///   - timeSignature: Time signature for added event
    ///   - ticksPerMetronomeClick: MIDI clocks between metronome clicks (not PPQN), typically 24
    ///   - thirtySecondNotesPerQuarter: Number of 32nd notes making a quarter, typically 8
    ///   - clearExistingEvents: Flag that will clear other Time Signature Events from tempo track
    ///
    public func addTimeSignatureEvent(at timeStamp: MusicTimeStamp = 0.0,
                                      timeSignature: TimeSignature,
                                      ticksPerMetronomeClick: MIDIByte = 24,
                                      thirtySecondNotesPerQuarter: MIDIByte = 8,
                                      clearExistingEvents: Bool = true)
    {
        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        guard let unwrappedTempoTrack = tempoTrack else {
            Log("Couldn't get tempo track")
            return
        }

        if clearExistingEvents {
            clearTimeSignatureEvents(unwrappedTempoTrack)
        }

        let data: [MIDIByte] = [timeSignature.topValue,
                                timeSignature.bottomValue.rawValue,
                                ticksPerMetronomeClick,
                                thirtySecondNotesPerQuarter]

        let metaEventPtr = MIDIMetaEvent.allocate(metaEventType: 0x58, // i.e, set time signature
                                                  data: data)

        defer { metaEventPtr.deallocate() }

        let result = MusicTrackNewMetaEvent(unwrappedTempoTrack, timeStamp, metaEventPtr)
        if result != 0 {
            Log("Unable to set time signature")
        }
    }

    /// Remove existing time signature events from tempo track
    func clearTimeSignatureEvents(_ track: MusicTrack) {
        let timeSignatureMetaEventByte: MIDIByte = 0x58
        let metaEventType = kMusicEventType_Meta

        MusicTrackManager.iterateMusicTrack(track) { iterator, _, eventType, eventData, _, isReadyForNextEvent in
            isReadyForNextEvent = true
            guard eventType == metaEventType else { return }

            let data = eventData?.bindMemory(to: MIDIMetaEvent.self, capacity: 1)
            guard let dataMetaEventType = data?.pointee.metaEventType else { return }

            if dataMetaEventType == timeSignatureMetaEventByte {
                MusicEventIteratorDeleteEvent(iterator)
                isReadyForNextEvent = false
            }
        }
    }

    // MARK: - Duration

    /// Convert seconds into Duration
    ///
    /// - parameter seconds: time in seconds
    ///
    public func duration(seconds: Double) -> Duration {
        let sign = seconds > 0 ? 1.0 : -1.0
        let absoluteValueSeconds = fabs(seconds)
        var outBeats = Duration(beats: MusicTimeStamp())
        if let existingSequence = sequence {
            MusicSequenceGetBeatsForSeconds(existingSequence, Float64(absoluteValueSeconds), &outBeats.beats)
        }
        outBeats.beats *= sign
        return outBeats
    }

    /// Convert beats into seconds
    ///
    /// - parameter duration: Duration
    ///
    public func seconds(duration: Duration) -> Double {
        let sign = duration.beats > 0 ? 1.0 : -1.0
        let absoluteValueBeats = fabs(duration.beats)
        var outSecs: Double = MusicTimeStamp()
        if let existingSequence = sequence {
            MusicSequenceGetSecondsForBeats(existingSequence, absoluteValueBeats, &outSecs)
        }
        outSecs *= sign
        return outSecs
    }

    // MARK: - Transport Control

    /// Play the sequence
    public func play() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerStart(existingMusicPlayer)
        }
    }

    /// Stop the sequence
    public func stop() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerStop(existingMusicPlayer)
        }
    }

    /// Rewind the sequence
    public func rewind() {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetTime(existingMusicPlayer, 0)
        }
    }

    /// Whether or not the sequencer is currently playing
    open var isPlaying: Bool {
        var isPlayingBool: DarwinBoolean = false
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerIsPlaying(existingMusicPlayer, &isPlayingBool)
        }
        return isPlayingBool.boolValue
    }

    /// Current Time
    open var currentPosition: Duration {
        var currentTime = MusicTimeStamp()
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerGetTime(existingMusicPlayer, &currentTime)
        }
        let duration = Duration(beats: currentTime)
        return duration
    }

    /// Current Time relative to sequencer length
    open var currentRelativePosition: Duration {
        return currentPosition % length // can switch to modTime func when/if % is removed
    }

    // MARK: - Other Sequence Properties

    /// Track count
    open var trackCount: Int {
        var count: UInt32 = 0
        if let existingSequence = sequence {
            MusicSequenceGetTrackCount(existingSequence, &count)
        }
        return Int(count)
    }

    /// Time Resolution, i.e., Pulses per quarter note
    open var timeResolution: UInt32 {
        let failedValue: UInt32 = 0
        guard let existingSequence = sequence else {
            Log("Couldn't get sequence for time resolution")
            return failedValue
        }
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)

        guard let unwrappedTempoTrack = tempoTrack else {
            Log("No tempo track for time resolution")
            return failedValue
        }

        var ppqn: UInt32 = 0
        var propertyLength: UInt32 = 0

        MusicTrackGetProperty(unwrappedTempoTrack,
                              kSequenceTrackProperty_TimeResolution,
                              &ppqn,
                              &propertyLength)

        return ppqn
    }

    // MARK: - Loading MIDI files

    /// Load a MIDI file from the bundle (removes old tracks, if present)
    public func loadMIDIFile(_ filename: String) {
        let bundle = Bundle.main
        guard let file = bundle.path(forResource: filename, ofType: "mid") else {
            Log("No midi file found")
            return
        }
        let fileURL = URL(fileURLWithPath: file)
        loadMIDIFile(fromURL: fileURL)
    }

    /// Load a MIDI file given a URL (removes old tracks, if present)
    public func loadMIDIFile(fromURL fileURL: URL) {
        removeTracks()
        if let existingSequence = sequence {
            let status: OSStatus = MusicSequenceFileLoad(existingSequence,
                                                         fileURL as CFURL,
                                                         .midiType,
                                                         MusicSequenceLoadFlags())
            if status != OSStatus(noErr) {
                Log("error reading midi file url: \(fileURL), read status: \(status)")
            }
        }
        initTracks()
    }

    /// Load a MIDI file given its data representation (removes old tracks, if present)
    public func loadMIDIFile(fromData data: Data) {
        removeTracks()
        if let existingSequence = sequence {
            let status: OSStatus = MusicSequenceFileLoadData(existingSequence,
                                                             data as CFData,
                                                             .midiType,
                                                             MusicSequenceLoadFlags())
            if status != OSStatus(noErr) {
                Log("error reading midi data, read status: \(status)")
            }
        }
        initTracks()
    }

    // MARK: - Adding MIDI File data to current sequencer

    /// Add tracks from MIDI file to existing sequencer
    ///
    /// - Parameters:
    ///   - filename: Location of the MIDI File
    ///   - useExistingSequencerLength: flag for automatically setting length of new track to current sequence length
    ///
    ///  Will copy only MIDINoteMessage events
    public func addMIDIFileTracks(_ filename: String, useExistingSequencerLength: Bool = true) {
        let tempSequencer = AppleSequencer(filename: filename)
        addMusicTrackNoteData(from: tempSequencer, useExistingSequencerLength: useExistingSequencerLength)
    }

    /// Add tracks from MIDI file to existing sequencer
    ///
    /// - Parameters:
    ///   - filename: fromURL: URL of MIDI File
    ///   - useExistingSequencerLength: flag for automatically setting length of new track to current sequence length
    ///
    ///  Will copy only MIDINoteMessage events
    public func addMIDIFileTracks(_ url: URL, useExistingSequencerLength: Bool = true) {
        let tempSequencer = AppleSequencer(fromURL: url)
        addMusicTrackNoteData(from: tempSequencer, useExistingSequencerLength: useExistingSequencerLength)
    }

    /// Creates new MusicTrackManager with copied note event data from another AppleSequencer
    func addMusicTrackNoteData(from tempSequencer: AppleSequencer, useExistingSequencerLength: Bool) {
        guard !isPlaying else {
            Log("Can't add tracks during playback")
            return
        }

        let oldLength = length
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
                tracks.append(MusicTrackManager(musicTrack: existingMusicTrack, name: "InitializedTrack"))
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
                clearTimeSignatureEvents(track)
                clearTempoEvents(track)
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
    public func newTrack(_ name: String = "Unnamed") -> MusicTrackManager? {
        guard let existingSequence = sequence else { return nil }
        var newMusicTrack: MusicTrack?
        MusicSequenceNewTrack(existingSequence, &newMusicTrack)
        guard let musicTrack = newMusicTrack else { return nil }
        let newTrack = MusicTrackManager(musicTrack: musicTrack, name: name)
        tracks.append(newTrack)
        return newTrack
    }

    // MARK: - Delete Tracks

    /// Delete track and remove it from the sequence
    /// Not to be used during playback
    public func deleteTrack(trackIndex: Int) {
        guard !isPlaying else {
            Log("Can't delete sequencer track during playback")
            return
        }
        guard trackIndex < tracks.count,
              let internalTrack = tracks[trackIndex].internalMusicTrack
        else {
            Log("Can't get track for index")
            return
        }

        guard let existingSequence = sequence else {
            Log("Can't get sequence")
            return
        }

        MusicSequenceDisposeTrack(existingSequence, internalTrack)
        tracks.remove(at: trackIndex)
    }

    /// Clear all non-tempo events from all tracks within the specified range
    //
    /// - Parameters:
    ///   - start: Start of the range to clear, in beats (inclusive)
    ///   - duration: Length of time after the start position to clear, in beats (exclusive)
    ///
    public func clearRange(start: Duration, duration: Duration) {
        for track in tracks {
            track.clearRange(start: start, duration: duration)
        }
    }

    /// Set the music player time directly
    ///
    /// - parameter time: Music time stamp to set
    ///
    public func setTime(_ time: MusicTimeStamp) {
        if let existingMusicPlayer = musicPlayer {
            MusicPlayerSetTime(existingMusicPlayer, time)
        }
    }

    /// Generate NSData from the sequence
    public func genData() -> Data? {
        var status = noErr
        var ns = Data()
        var data: Unmanaged<CFData>?
        if let existingSequence = sequence {
            status = MusicSequenceFileCreateData(existingSequence, .midiType, .eraseFile, 480, &data)

            if status != noErr {
                Log("error creating MusicSequence Data")
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
    public func debug() {
        if let existingPointer = sequencePointer {
            CAShow(existingPointer)
        }
    }

    /// Set the midi output for all tracks
    @available(tvOS 12.0, *)
    public func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
        for track in tracks {
            track.setMIDIOutput(midiEndpoint)
        }
    }

    /// Nearest time of quantized beat
    public func nearestQuantizedPosition(quantizationInBeats: Double) -> Duration {
        let noteOnTimeRel = currentRelativePosition.beats
        let quantizationPositions = getQuantizationPositions(quantizationInBeats: quantizationInBeats)
        let lastSpot = quantizationPositions[0]
        let nextSpot = quantizationPositions[1]
        let diffToLastSpot = Duration(beats: noteOnTimeRel) - lastSpot
        let diffToNextSpot = nextSpot - Duration(beats: noteOnTimeRel)
        let optimisedQuantTime = (diffToLastSpot < diffToNextSpot ? lastSpot : nextSpot)
        return optimisedQuantTime
    }

    /// The last quantized beat
    public func previousQuantizedPosition(quantizationInBeats: Double) -> Duration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[0]
    }

    /// Next quantized beat
    public func nextQuantizedPosition(quantizationInBeats: Double) -> Duration {
        return getQuantizationPositions(quantizationInBeats: quantizationInBeats)[1]
    }

    /// An array of all quantization points
    func getQuantizationPositions(quantizationInBeats: Double) -> [Duration] {
        let noteOnTimeRel = currentRelativePosition.beats
        let lastSpot = Duration(beats:
            modTime(noteOnTimeRel - noteOnTimeRel.truncatingRemainder(dividingBy: quantizationInBeats)))
        let nextSpot = Duration(beats: modTime(lastSpot.beats + quantizationInBeats))
        return [lastSpot, nextSpot]
    }

    /// Time modulus
    func modTime(_ time: Double) -> Double {
        return time.truncatingRemainder(dividingBy: length.beats)
    }

    // MARK: - Time Conversion

    public enum MusicPlayerTimeConversionError: Error {
        case musicPlayerIsNotPlaying
        case osStatus(OSStatus)
    }

    /// Returns the host time that will be (or was) played at the specified beat.
    /// This function is valid only if the music player is playing.
    public func hostTime(forBeats inBeats: AVMusicTimeStamp) throws -> UInt64 {
        guard let musicPlayer = musicPlayer, isPlaying else {
            throw MusicPlayerTimeConversionError.musicPlayerIsNotPlaying
        }
        var hostTime: UInt64 = 0
        let code = MusicPlayerGetHostTimeForBeats(musicPlayer, inBeats, &hostTime)
        guard code == noErr else {
            throw MusicPlayerTimeConversionError.osStatus(code)
        }
        return hostTime
    }

    /// Returns the beat that will be (or was) played at the specified host time.
    /// This function is valid only if the music player is playing.
    public func beats(forHostTime inHostTime: UInt64) throws -> AVMusicTimeStamp {
        guard let musicPlayer = musicPlayer, isPlaying else {
            throw MusicPlayerTimeConversionError.musicPlayerIsNotPlaying
        }
        var beats: MusicTimeStamp = 0
        let code = MusicPlayerGetBeatsForHostTime(musicPlayer, inHostTime, &beats)
        guard code == noErr else {
            throw MusicPlayerTimeConversionError.osStatus(code)
        }
        return beats
    }
}
