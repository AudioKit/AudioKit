//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSequencerTrack {

    var engine: AKSequencerTrackEngine!
    public var trackID: Int = 0
    public var events: [AKMIDIEvent] {
        return _events
    }
    var _events = [AKMIDIEvent]()
    public var noteOffset: Int = 0 {
        didSet {
            engine.noteOffset = Int32(noteOffset)
        }
    }
    public var timeMultiplier: Double = 1 {
        didSet {
            engine.multiplier = timeMultiplier
        }
    }

    init(target node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(node: node, index: Int32(index))
    }

    public func addNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double){
        engine.addNote(noteNumber, velocity: velocity, at: at, duration: duration)
    }

    public func play() {
        engine.play()
    }

    public func stop() {
        engine.stop()
    }

    public func seek(to time: Double, at position: AVAudioTime? = nil) {
        engine.setBeatTime(time, at: position)
    }
    
    public func clear() {
        engine.clear()
    }

    public func stopAllNotes() {
        engine.stopAllNotes()
    }

}
