//
//  DIYSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/8/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

class DIYSeq {

    var tracks = [DIYSeqTrack]()

    required public init(_ nodes: [AKNode]) {
        tracks = nodes.enumerated().map({ DIYSeqTrack(targetNode: $0.element) })
    }

    public convenience init(_ node: AKNode? = nil) {
        if let node = node {
            self.init([node])
        } else {
            self.init([AKNode]())
        }
    }
    public convenience init(fromURL fileURL: URL, nodes: [AKNode]) {
        self.init(nodes)
        let midiFile = AKMIDIFile(url: fileURL)
        let tracks = midiFile.tracks
        if tracks.count > nodes.count {
            AKLog("Error: Track count and node count do not match, dropped \(tracks.count - nodes.count) tracks")
        }
        for node in nodes.enumerated() {
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
