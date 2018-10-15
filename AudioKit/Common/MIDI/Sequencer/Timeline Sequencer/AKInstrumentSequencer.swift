//
//  AKInstrumentSequencer.swift
//  SuperSequencer
//
//  Created by Aurelius Prochazka on 8/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

struct SequencedNote {
    let noteNumber: MIDINoteNumber
    let velocity: MIDIVelocity
    let beat: Double
}

open class AKInstrumentSequencer {

    init(target: AKNode) {
        tracks.append(AKSequencerTrack(target: target))
        internalSequencer = AKTimelineSequencer(node: target)
    }

    var internalSequencer:AKTimelineSequencer

    var timeline: AKTimeline?
    var tracks = [AKSequencerTrack]()
    var sampler = AKTimelineSequencer()
    var sequence = [SequencedNote]() {
        didSet {
            sampler.clear()
            for note in sequence {
                sampler.addNote(note.noteNumber, velocity: note.velocity, at: note.beat)
            }
        }
    }

    func stop() {
        sampler.stop()
    }

    func play() {
        sampler.setBeatTime(0.0, at: nil)
        sampler.play()
    }

}
