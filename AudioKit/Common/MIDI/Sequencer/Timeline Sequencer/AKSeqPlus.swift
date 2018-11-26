//
//  AKSeqPlus.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/26/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSeqPlus {

    var timeline = AKTimeline()
    var tracks: [AKSequencerTrackPlus] = []

    public init(_ nodes: AKNode...) {
        for (index, node) in nodes.enumerated() {
            tracks.append(AKSequencerTrackPlus(node, index: index))
        }
    }
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

    public func track(for node: AKNode) -> AKSequencerTrackPlus? {
        return tracks.first(where: { $0.targetNode == node })
    }

    public func stopAllNotes() {
        for track in tracks { track.stopAfterCurrentNotes() }
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
        tracks.append(AKSequencerTrackPlus(node, index: id))
        return id
    }

    @discardableResult public func add(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode) -> Int {
        let id = tracks.count
        tracks.append(AKSequencerTrackPlus(midiPort: midiPort, midiEndpoint: midiEndpoint, node: node, index: tracks.count))
        return id
    }

    public func loadMIDIFile(path: String) {
        print("loadind file at \(path)")
        let file = AKMIDIFile(path: path)
        for track in file.trackChunks {
            let events = track.events
        }
    }

    public func debugEvents() {
        for track in tracks { track.debugEvents() }
    }

}
