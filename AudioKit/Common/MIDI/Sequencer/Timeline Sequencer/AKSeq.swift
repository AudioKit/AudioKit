//
//  AKSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSeq {

    var timeline = AKTimeline()
    public var tracks = [AKSequencerTrack]()

    public var lengthInBeats: Double = 1.0 {
        didSet {
            for track in tracks { track.lengthInBeats = lengthInBeats }
        }
    }

    public var tempo: Double = 120.0 {
        didSet {
            for track in tracks { track.tempo = tempo }
        }
    }

    public var loopEnabled: Bool = true {
        didSet {
            for track in tracks { track.loopEnabled = loopEnabled }
        }
    }

    public var loopCount: UInt = 0 {
        didSet {
            for track in tracks { track.loopCount = loopCount }
        }
    }

    public var isPlaying: Bool {
        return tracks.contains(where: { $0.isPlaying })
    }

    public var currentPosition: AKDuration {
        return tracks.first?.currentPosition ?? AKDuration(beats: 0)
    }

    public func track(for node: AKNode) -> AKSequencerTrack? {
        return tracks.first(where: { $0.targetNode == node })
    }

    public func stopAllNotes() {
        for track in tracks { track.stopAfterCurrentNotes() }
    }

    public init(_ nodes: AKNode...) {
        for (index, node) in nodes.enumerated() {
            tracks.append(AKSequencerTrack(node, index: index))
        }
    }

    public func play() {
        for track in tracks {
            track.engine.setBeatTime(0, at: nil)
            track.play()
        }
    }

    func playOnNextBeat(at beatTime: Double = 0) {
        for track in tracks {
            track.playOnNextBeat(at: beatTime)
        }
    }

    public func stop() {
        for track in tracks { track.stop() }
    }

    public func seek(to beat: Double, at time: AVAudioTime) {
        for track in tracks { track.seek(to: beat, at: time) }
    }

    @discardableResult public func add(node: AKNode) -> Int {
        let id = tracks.count
        tracks.append(AKSequencerTrack(node, index: id))
        return id
    }

    @discardableResult public func add(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode) -> Int {
        let id = tracks.count
        tracks.append(AKSequencerTrack(midiPort: midiPort, midiEndpoint: midiEndpoint, node: node, index: tracks.count))
        return id
    }
    
    public func loadMIDIFile(path: String) {
        print("loadind file at \(path)")
        let file = AKMIDIFile(path: path)
        for track in file.trackChunks {
            let _ = track.chunkEvents
        }
    }

    public func debugEvents() {
        for track in tracks { track.debugEvents() }
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
