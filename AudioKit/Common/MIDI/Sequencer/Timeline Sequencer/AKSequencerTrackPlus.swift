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
            let swingInterval = beatsPerBar * quantisation
            for i in 0..<notes.count {
                if notes[i].position.truncatingRemainder(dividingBy: swingInterval * 2) == swingInterval {
                    let swingAmount = swing * swingInterval
                    print("will swing at position \(notes[i].position) by \(swingAmount)")
                    notes[i].noteOnEvent.modifyPosition(by: swingAmount)
                }
            }
            updateSequence()
        }
    }

    public var quantisation: Double = 1/16
    public var quantisationStrength: Double = 1.0

    public var notes: [NoteOnOffEvent] = [] {
        didSet {
            updateSequence()
        }
    }

    public override func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double) {
        var noteEvent = NoteOnOffEvent(noteNumber: noteNumber, velocity: velocity, channel: 0,
                                       position: at, duration: duration)
        noteEvent.quantise(to: quantisation, strength: quantisationStrength)
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

    mutating func quantise(to amount: Double, strength: Double = 1.0, preference: QuantisationPreference = .nearest) {
        guard amount != 0 else {
            return
        }
        let beatsPerBar = 4.0
        let quantisationIntervals = beatsPerBar * amount
        let positionStep = position / quantisationIntervals
        var stepMultiplier: Double = 0
        switch preference {
        case .higher:
            stepMultiplier = ceil(positionStep)
        case .lower:
            stepMultiplier = floor(positionStep)
        case .nearest:
            stepMultiplier = round(positionStep)
        }
        let quantisedStep = stepMultiplier * quantisationIntervals
        let modifier = (quantisedStep - noteOnEvent.basePosition) * strength
        print("quant result for \(noteOnEvent.basePosition) is \(quantisedStep) modifier is \(modifier)")
        noteOnEvent.positionModifier = modifier
    }

    public init(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, position: Double,
                duration: Double){
        noteOnEvent = SequenceNoteEvent(event: AKMIDIEvent.init(noteOn: noteNumber, velocity: velocity, channel: channel), position: position)
        self.duration = duration
    }
}

enum QuantisationPreference {
    case higher
    case lower
    case nearest
}
