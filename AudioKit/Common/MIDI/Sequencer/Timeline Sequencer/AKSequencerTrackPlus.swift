//
//  AKSequencerTrackPlus.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/26/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSequencerTrackPlus: AKSequencerTrack {

    public var swing: Double = 0.0 { 
        didSet{
            let beatsPerBar = 4.0
            let swingIntervals = beatsPerBar / swingInterval
            for i in 0..<notes.count {
                if notes[i].position.truncatingRemainder(dividingBy: swingIntervals * 2) == swingIntervals {
                    let swingAmount = swing * swingIntervals
                    print("will swing at position \(notes[i].position) by \(swingAmount)")
                    notes[i].noteOnEvent.modifyPosition(by: swingAmount)
                }
            }
            updateSequence()
        }
    }

    public var swingInterval: Double = 16

    public var notes: [NoteOnOffEvent] = [] {
        didSet {
            updateSequence()
        }
    }

    public override func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double) {
        let noteEvent = NoteOnOffEvent(noteNumber: noteNumber, velocity: velocity, channel: 0,
                                       position: at, duration: duration)
        notes.append(noteEvent)
    }

    public override func clear() {
        notes.removeAll()
        updateSequence()
    }

    public func updateSequence() {
        engine.clear()
        for notePair in notes {
            add(event: notePair.noteOnEvent.event, at: notePair.noteOnEvent.position)
            add(event: notePair.noteOffEvent.event, at: notePair.noteOffEvent.position)
        }
    }
}

public struct NoteOnOffEvent {
    var duration = 0.1
    var noteOnEvent: SequenceNoteEvent
    var noteOffEvent: SequenceNoteEvent {
        let event = AKMIDIEvent(noteOff: noteOnEvent.event.bytes[1], velocity: 0,
                                channel: noteOnEvent.event.channel ?? 0)
        return SequenceNoteEvent(event: event, position: noteOnEvent.position + duration)
    }

    var position: Double {
        return noteOnEvent.position
    }

    public init(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, position: Double,
                duration: Double){
        noteOnEvent = SequenceNoteEvent(event: AKMIDIEvent.init(noteOn: noteNumber, velocity: velocity, channel: channel), position: position)
        self.duration = duration
    }
}
