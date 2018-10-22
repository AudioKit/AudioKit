//
//  AKSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/17/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKSeq {
    
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
    public var loopEnabled: Bool = true{
        didSet {
            for track in tracks { track.loopEnabled = loopEnabled }
        }
    }

    var timeline = AKTimeline()

    public func stopAllNotes() {
        for track in tracks { track.stopAllNotes() }
    }

    public func play() {
        for track in tracks {
            track.engine.setBeatTime(0, at: nil)
            track.play()
        }
    }

    public func stop() {
        for track in tracks { track.stop() }
    }

    public func seek(to beat: Double, at time: AVAudioTime) {
        for track in tracks { track.seek(to: beat, at: time) }
    }

    public init(_ nodes: AKNode...) {
        for (index, node) in nodes.enumerated() {
            tracks.append(AKSequencerTrack(node, index: index))
        }
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
}
