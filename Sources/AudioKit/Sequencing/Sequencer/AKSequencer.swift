// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation

/// Open-source AudioKit Sequencer
///
/// Up until AudioKit 4.8, this was a different class. The old class is now renamed "AKAppleSequencer"
open class AKSequencer {

    /// Array of sequencer tracks
    open var tracks = [AKSequencerTrack]()

    /// Overall playback speed
    open var tempo: BPM {
        get { return tracks.first?.tempo ?? 0 }
        set { for track in tracks { track.tempo = newValue } }
    }

    /// Length in beats
    open var length: Double {
        get { return tracks.max(by: { $0.length > $1.length })?.length ?? 0 }
        set { for track in tracks { track.length = newValue } }
    }

    /// Whether or not looping is enabled
    open var loopEnabled: Bool {
        get { return tracks.first?.loopEnabled ?? false }
        set { for track in tracks { track.loopEnabled = newValue } }
    }

    /// Is the sequencer currently playing
    open var isPlaying: Bool {
        return tracks.first?.isPlaying ?? false
    }

    /// Initialize with a single node or with no node at all
    /// You must provide a target node for the sequencer to drive or it will not run at all
    /// - Parameter targetNode: Required node
    public convenience init(targetNode: AKNode) {
        self.init(targetNodes: [targetNode])
    }

    /// Initialize with target nodes. This will create a track for each node
    /// - Parameter targetNodes: Array of nodes to target for each track
    public required init(targetNodes: [AKNode]? = nil) {
        if let targetNodes = targetNodes {
            tracks = targetNodes.enumerated().map({ AKSequencerTrack(targetNode: $0.element) })
        } else {
            AKLog("no nodes connected to sequencer at init - be sure to connect some via addTrack")
        }
    }

    /// Initialize the sequencer from a MIDI File
    /// - Parameters:
    ///   - fileURL: Location of the MIDI File
    ///   - targetNodes: Nodes to place the tracks from the MIDI file into
    public convenience init(fromURL fileURL: URL, targetNodes: [AKNode]) {
        self.init(targetNodes: targetNodes)
        load(midiFileURL: fileURL)
    }

    /// Start playback of the track from the current position (like unpause)
    public func play() {
        for track in tracks { track.play() }
    }

    /// Start the playback of the track from the beginning
    public func playFromStart() {
        for track in tracks { track.playFromStart() }
    }

    /// Start playback after a certain number of beats
    public func playAfterDelay(beats: Double) {
        for track in tracks { track.playAfterDelay(beats: beats) }
    }

    /// Stop playback
    public func stop() {
        for track in tracks { track.stop() }
    }

    /// Rewind playback
    public func rewind() {
        for track in tracks { track.rewind() }
    }

    /// Load MIDI data from a file URL
    public func load(midiFileURL: URL) {
        load(midiFile: AKMIDIFile(url: midiFileURL))
    }

    /// Load MIDI data from a file
    /// - Parameter midiFile: MIDI File to load data out of
    public func load(midiFile: AKMIDIFile) {
        let midiTracks = midiFile.tracks
        if midiTracks.count > tracks.count {
            AKLog("Error: Track count and file track count do not match ",
                  "dropped \(midiTracks.count - tracks.count) tracks")
        }
        if tracks.count > midiTracks.count {
            AKLog("Error: Track count less than file track count, ignoring \(tracks.count - midiTracks.count) nodes")
        }
        for index in 0..<min(midiTracks.count, tracks.count) {
            let track = midiTracks[index]
            tracks[index].clear()
            var sequence = AKSequence()
            for event in track.channelEvents {
                if let pos = event.positionInBeats {
                    sequence.add(event: event, position: pos)
                }
            }
            self.tracks[index].sequence = sequence
            self.tracks[index].length = track.length
        }
        length = self.tracks.max(by: { $0.length > $1.length })?.length ?? 0
    }

    /// Add a MIDI note to the track
    /// - Parameters:
    ///   - noteNumber: MIDI Note number to add
    ///   - velocity: Velocity of the note
    ///   - channel: Channel to place the note on
    ///   - position: Location in beats of the new note
    ///   - duration: Duration in beats of the new note
    ///   - trackIndex: Which track to add the note to
    public func add(noteNumber: MIDINoteNumber,
                    velocity: MIDIVelocity = 127,
                    channel: MIDIChannel = 0,
                    position: Double,
                    duration: Double,
                    trackIndex: Int = 0) {
        guard tracks.count > trackIndex, trackIndex >= 0 else {
            AKLog("Track index \(trackIndex) out of range (sequencer has \(tracks.count) tracks)")
            return
        }
        tracks[trackIndex].sequence.add(noteNumber: noteNumber,
                                        velocity: velocity,
                                        channel: channel,
                                        position: position,
                                        duration: duration)
    }

    /// Add a MIDI event to the track
    /// - Parameters:
    ///   - event: Event to add
    ///   - position: Location in time in beats to add the event at
    ///   - trackIndex: Which track to add the event
    public func add(event: AKMIDIEvent, position: Double, trackIndex: Int = 0) {
        guard tracks.count > trackIndex, trackIndex >= 0 else {
            AKLog("Track index \(trackIndex) out of range (sequencer has \(tracks.count) tracks)")
            return
        }
        tracks[trackIndex].sequence.add(event: event,
                                        position: position)
    }

    /// Remove all notes
    public func clear() {
        for track in tracks {
            track.clear()
        }
    }

    /// Move to a new time in the playback
    /// - Parameter position: Time to jump to, in beats
    public func seek(to position: Double) {
        tracks.forEach({ $0.seek(to: position) })
    }

    /// Equivalent to stop
    public func pause() {
        stop()
    }

    /// Retrived a track for a given node
    /// - Parameter node: Node you want to access the tack for
    /// - Returns: Track associated with the given node
    public func getTrackFor(node: AKNode) -> AKSequencerTrack? {
        return tracks.first(where: { $0.targetNode === node })
    }

    /// Add track associated with a node
    /// - Parameter node: Node to create the track for
    /// - Returns: Track associated with the given node
    public func addTrack(for node: AKNode) -> AKSequencerTrack {
        let track = AKSequencerTrack(targetNode: node)
        tracks.append(track)
        return track
    }
}

#endif

/* functions from AKAppleSequencer  to implement

 public convenience init(fromURL fileURL: URL) {
 open func enableLooping(_ loopLength: AKDuration) {
 open func setLoopInfo(_ duration: AKDuration, numberOfLoops: Int) {
 open func setLength(_ length: AKDuration) {
 open var length: AKDuration {
 open func setRate(_ rate: Double) {
 open func setTempo(_ bpm: Double) {
 open func addTempoEventAt(tempo bpm: Double, position: AKDuration) {
 open var tempo: Double {
 open func getTempo(at position: MusicTimeStamp) -> Double {
 func clearTempoEvents(_ track: MusicTrack) {
 open func duration(seconds: Double) -> AKDuration {
 open func seconds(duration: AKDuration) -> Double {
 open func rewind() {
 open var isPlaying: Bool {
 open var currentPosition: AKDuration {
 open var currentRelativePosition: AKDuration {
 open var trackCount: Int {
 open func loadMIDIFile(_ filename: String) {
 open func loadMIDIFile(fromURL fileURL: URL) {
 open func addMIDIFileTracks(_ filename: String, useExistingSequencerLength: Bool = true) {
 open func addMIDIFileTracks(_ url: URL, useExistingSequencerLength: Bool = true) {
 open func newTrack(_ name: String = "Unnamed") -> AKMusicTrack? {
 open func deleteTrack(trackIndex: Int) {
 open func clearRange(start: AKDuration, duration: AKDuration) {
 open func setTime(_ time: MusicTimeStamp) {
 open func genData() -> Data? {
 open func debug() {
 open func setGlobalMIDIOutput(_ midiEndpoint: MIDIEndpointRef) {
 open func nearestQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 open func previousQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 open func nextQuantizedPosition(quantizationInBeats: Double) -> AKDuration {
 func getQuantizationPositions(quantizationInBeats: Double) -> [AKDuration] {

 */
