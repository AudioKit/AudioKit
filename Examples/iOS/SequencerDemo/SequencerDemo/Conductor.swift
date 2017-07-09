//
//  Conductor.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {

    var fmOscillator = AKFMOscillatorBank()
    var melodicSound: AKMIDINode!
    var verb: AKReverb2!

    var bassDrum = AKSynthKick()
    var snareDrum = AKSynthSnare()
    var snareGhost = AKSynthSnare(duration: 0.06, resonance: 0.3)
    var snareMixer = AKMixer()
    var snareVerb: AKReverb!

    var sequencer = AKSequencer()
    var mixer = AKMixer()
    var pumper: AKCompressor!

    var currentTempo = 110.0 {
        didSet {
            sequencer.setTempo(currentTempo)
        }
    }

    let scale1: [Int] = [0, 2, 4, 7, 9]
    let scale2: [Int] = [0, 3, 5, 7, 10]
    let sequenceLength = AKDuration(beats: 8.0)

    init() {
        fmOscillator.modulatingMultiplier = 3
        fmOscillator.modulationIndex = 0.3

        melodicSound = AKMIDINode(node: fmOscillator)
        verb = AKReverb2(melodicSound)
        verb.dryWetMix = 0.5
        verb.decayTimeAt0Hz = 7
        verb.decayTimeAtNyquist = 11
        verb.randomizeReflections = 600
        verb.gain = 1

        snareMixer.connect(snareDrum)
        snareMixer.connect(snareGhost)
        snareVerb = AKReverb(snareMixer)

        pumper = AKCompressor(mixer)

        pumper.headRoom = 0.10
        pumper.threshold = -15
        pumper.masterGain = 10
        pumper.attackTime = 0.01
        pumper.releaseTime = 0.3

        mixer.connect(verb)
        mixer.connect(bassDrum)
        mixer.connect(snareDrum)
        mixer.connect(snareGhost)
        mixer.connect(snareVerb)

        AudioKit.output = pumper
        AudioKit.start()
    }

    func setupTracks() {
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[Sequence.melody.rawValue].setMIDIOutput(melodicSound.midiIn)
        generateNewMelodicSequence(minor: false)

        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.bassDrum.rawValue].setMIDIOutput(bassDrum.midiIn)
        generateBassDrumSequence()

        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.snareDrum.rawValue].setMIDIOutput(snareDrum.midiIn)
        generateSnareDrumSequence()

        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.snareGhost.rawValue].setMIDIOutput(snareGhost.midiIn)
        generateSnareDrumGhostSequence()

        sequencer.enableLooping()
        sequencer.setTempo(100)
        sequencer.play()
    }

    func generateNewMelodicSequence(_ stepSize: Float = 1 / 8, minor: Bool = false, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.melody.rawValue].clear() }
        sequencer.setLength(sequenceLength)
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        //print("steps in sequence: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 12 {
                let step = Double(i) * stepSize
                //print("step is \(step)")
                let scale = (minor ? scale2 : scale1)
                let scaleOffset = arc4random_uniform(UInt32(scale.count) - 1)
                var octaveOffset = 0
                for _ in 0 ..< 2 {
                    octaveOffset += Int(12 * (((Float(arc4random_uniform(2))) * 2.0) + (-1.0)))
                    octaveOffset = Int(
                        (Float(arc4random_uniform(2))) *
                        (Float(arc4random_uniform(2))) *
                        Float(octaveOffset)
                    )
                }
                //print("octave offset is \(octaveOffset)")
                let noteToAdd = 60 + scale[Int(scaleOffset)] + octaveOffset
                sequencer.tracks[Sequence.melody.rawValue].add(noteNumber: MIDINoteNumber(noteToAdd),
                                                               velocity: 100,
                                                               position: AKDuration(beats: step),
                                                               duration: AKDuration(beats: 1))
            }
        }
        sequencer.setLength(sequenceLength)
    }

    func generateBassDrumSequence(_ stepSize: Float = 1, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.bassDrum.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        for i in 0 ..< numberOfSteps {
            let step = Double(i) * stepSize

            sequencer.tracks[Sequence.bassDrum.rawValue].add(noteNumber: 60,
                                                             velocity: 100,
                                                             position: AKDuration(beats: step),
                                                             duration: AKDuration(beats: 1))
        }
    }

    func generateSnareDrumSequence(_ stepSize: Float = 1, clear: Bool = true) {
        if clear { sequencer.tracks[2].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)

        for i in stride(from: 1, to: numberOfSteps, by: 2) {
            let step = (Double(i) * stepSize)
            sequencer.tracks[Sequence.snareDrum.rawValue].add(noteNumber: 60,
                                                              velocity: 80,
                                                              position: AKDuration(beats: step),
                                                              duration: AKDuration(beats: 1))
        }
    }

    func generateSnareDrumGhostSequence(_ stepSize: Float = 1 / 8, clear: Bool = true) {
        if clear { sequencer.tracks[Sequence.snareGhost.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        //print("steps in sequnce: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if arc4random_uniform(17) > 14 {
                let step = Double(i) * stepSize
                sequencer.tracks[Sequence.snareGhost.rawValue].add(noteNumber: 60,
                                                                   velocity: MIDIVelocity(arc4random_uniform(65) + 1),
                                                                   position: AKDuration(beats: step),
                                                                   duration: AKDuration(beats: 0.1))
            }
        }
        sequencer.setLength(sequenceLength)
    }

    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }

    func generateSequence() {
        generateNewMelodicSequence(minor: randomBool())
        generateBassDrumSequence()
        generateSnareDrumSequence()
        generateSnareDrumGhostSequence()
    }

    func clear(_ typeOfSequence: Sequence) {
        sequencer.tracks[typeOfSequence.rawValue].clear()
    }

}
