//
//  DIYSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/8/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

open class DIYSeq {

    open var tracks = [DIYSeqTrack]()
    open var tempo: BPM {
        get { return tracks.first?.tempo ?? 0 }
        set { for track in tracks { track.tempo = newValue } }
    }

    open var length: Double {
        get { return tracks.max(by: { $0.length > $1.length })?.length ?? 0 }
        set { for track in tracks { track.length = newValue } }
    }

    open func play() {
        for track in tracks { track.play() }
    }

    open func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity = 127, channel: MIDIChannel = 0,
                  position: Double, duration: Double, trackIndex: Int = 0) {
        guard tracks.count > trackIndex, trackIndex >= 0 else {
            AKLog("Track index \(trackIndex) out of range (sequencer has \(tracks.count) tracks)")
            return
        }
        tracks[trackIndex].add(noteNumber: noteNumber, velocity: velocity, channel: channel,
                               position: position, duration: duration)
    }

    open func add(event: AKMIDIEvent, position: Double, trackIndex: Int = 0) {
        guard tracks.count > trackIndex, trackIndex >= 0 else {
            AKLog("Track index \(trackIndex) out of range (sequencer has \(tracks.count) tracks)")
            return
        }
        tracks[trackIndex].add(event: event, position: position)
    }

    required public init(targetNodes: [AKNode]) {
        tracks = targetNodes.enumerated().map({ DIYSeqTrack(targetNode: $0.element) })
    }

    public convenience init(targetNode: AKNode? = nil) {
        if let node = targetNode {
            self.init(targetNodes: [node])
        } else {
            self.init(targetNodes: [AKNode]())
        }
    }

    public convenience init(fromURL fileURL: URL, targetNodes: [AKNode]) {
        self.init(targetNodes: targetNodes)
        let midiFile = AKMIDIFile(url: fileURL)
        let tracks = midiFile.tracks
        if tracks.count > targetNodes.count {
            AKLog("Error: Track count and node count do not match, dropped \(tracks.count - targetNodes.count) tracks")
        }
        for node in targetNodes.enumerated() {
            let index = node.offset
            let track = tracks[index]
            for event in track.events {
                if let pos = event.positionInBeats {
                    self.tracks[index].add(event: event, position: pos)
                }
            }
        }
    }
}


/* functions from aksequencer to implement

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
