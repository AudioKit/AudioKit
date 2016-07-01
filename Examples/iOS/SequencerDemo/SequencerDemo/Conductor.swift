//
//  Conductor.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    let midi = AKMIDI()
    
    var fmOscillator = AKFMOscillatorBank()
    var melodicSound: AKMIDINode?
    var verb: AKReverb2?
    
    var bassDrumInstrument: BDInstrument?
    var bassDrum: AKMIDIInstrument?
    
    var snareDrumInstrument: SDInstrument?
    var snareDrum: AKMIDIInstrument?
    var snareGhostInstrument: SDInstrument?
    var snareGhost: AKMIDIInstrument?
    var snareMixer = AKMixer()
    var snareVerb: AKReverb?
    
    var sequence = AKSequencer()
    var mixer = AKMixer()
    var pumper: AKCompressor?
    
    var currentTempo = 110.0
    
    let scale1: [Int] = [0, 2, 4, 7, 9]
    let scale2: [Int] = [0, 3, 5, 7, 10]
    let sequenceLength = Beat(8.0)

    init() {
        fmOscillator.modulatingMultiplier = 3
        fmOscillator.modulationIndex = 0.3
        
        melodicSound = AKMIDINode(node: fmOscillator)
        melodicSound?.enableMIDI(midi.client, name: "melodicSound midi in")
        verb = AKReverb2(melodicSound!)
        verb?.dryWetMix = 0.5
        verb?.decayTimeAt0Hz = 7
        verb?.decayTimeAtNyquist = 11
        verb?.randomizeReflections = 600
        verb?.gain = 1
        
        bassDrumInstrument = BDInstrument(voiceCount: 1)
        bassDrumInstrument?.amplitude = 1
        bassDrum = AKMIDIInstrument(instrument: bassDrumInstrument!)
        bassDrum?.enableMIDI(midi.client, name: "bassDrum midi in")
        
        snareDrumInstrument = SDInstrument(voiceCount: 1)
        snareDrumInstrument?.amplitude = 0.3
        snareDrum = AKMIDIInstrument(instrument: snareDrumInstrument!)
        snareDrum?.enableMIDI(midi.client, name: "snareDrum midi in")
        
        snareGhostInstrument = SDInstrument(voiceCount: 1, dur: 0.06, res: 0.3)
        snareGhostInstrument?.amplitude = 0.2
        snareGhost = AKMIDIInstrument(instrument: snareGhostInstrument!)
        snareGhost?.enableMIDI(midi.client, name: "snareGhost midi in")
        
        snareMixer.connect(snareDrum!)
        snareMixer.connect(snareGhost!)
        snareVerb = AKReverb(snareMixer)
        
        pumper = AKCompressor(mixer)
        
        pumper?.headRoom = 0.10
        pumper?.threshold = -15
        pumper?.masterGain = 15
        pumper?.attackTime = 0.01
        pumper?.releaseTime = 0.3
        
        mixer.connect(verb!)
        mixer.connect(bassDrum!)
        mixer.connect(snareDrum!)
        mixer.connect(snareGhost!)
        mixer.connect(snareVerb!)
        
        AudioKit.output = pumper
        AudioKit.start()
        
        sequence.newTrack()
        sequence.setLength(sequenceLength)
        sequence.tracks[Sequence.Melody.rawValue].setMIDIOutput((melodicSound?.midiIn)!)
        generateNewMelodicSequence(minor: false)
        
        sequence.newTrack()
        sequence.tracks[Sequence.BassDrum.rawValue].setMIDIOutput((bassDrum?.midiIn)!)
        generateBassDrumSequence()
        
        sequence.newTrack()
        sequence.tracks[Sequence.SnareDrum.rawValue].setMIDIOutput((snareDrum?.midiIn)!)
        generateSnareDrumSequence()
        
        sequence.newTrack()
        sequence.tracks[Sequence.SnareDrumGhost.rawValue].setMIDIOutput((snareGhost?.midiIn)!)
        generateSnareDrumGhostSequence()
        
        sequence.enableLooping()
        sequence.setTempo(100)
        sequence.play()
    }
    func generateNewMelodicSequence(stepSize: Float = 1/8, minor: Bool = false, clear: Bool = true) {
        if (clear) { sequence.tracks[Sequence.Melody.rawValue].clear() }
        sequence.setLength(sequenceLength)
        let numberOfSteps = Int(Float(sequenceLength.value)/stepSize)
        //print("steps in sequence: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if (arc4random_uniform(17) > 12) {
                let step = Double(i) * stepSize
                //print("step is \(step)")
                let scale = (minor ? scale2 : scale1)
                let scaleOffset = arc4random_uniform(UInt32(scale.count)-1)
                var octaveOffset = 0
                for _ in 0 ..< 2 {
                    octaveOffset += Int(12 * (((Float(arc4random_uniform(2)))*2.0)+(-1.0)))
                    octaveOffset = Int((Float(arc4random_uniform(2))) * (Float(arc4random_uniform(2))) * Float(octaveOffset))
                }
                //print("octave offset is \(octaveOffset)")
                let noteToAdd = 60 + scale[Int(scaleOffset)] + octaveOffset
                sequence.tracks[Sequence.Melody.rawValue].add(noteNumber: noteToAdd,
                                       velocity: 100,
                                       position: Beat(step),
                                       duration: Beat(1))
            }
        }
        sequence.setLength(sequenceLength)
    }
    
    func generateBassDrumSequence(stepSize: Float = 1, clear: Bool = true) {
        if (clear) { sequence.tracks[Sequence.BassDrum.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.value)/stepSize)
        for i in 0 ..< numberOfSteps {
            let step = Double(i) * stepSize
            
            sequence.tracks[Sequence.BassDrum.rawValue].add(noteNumber: 60,
                                   velocity: 100,
                                   position: Beat(step),
                                   duration: Beat(1))
        }
    }
    
    func generateSnareDrumSequence(stepSize: Float = 1, clear: Bool = true) {
        if (clear) { sequence.tracks[2].clear() }
        let numberOfSteps = Int(Float(sequenceLength.value)/stepSize)
        
        for i in 1.stride(to: numberOfSteps, by: 2) {
            let step = (Double(i) * stepSize)
            sequence.tracks[Sequence.SnareDrum.rawValue].add(noteNumber: 60,
                                   velocity: 80,
                                   position: Beat(step),
                                   duration: Beat(1))
        }
    }
    
    func generateSnareDrumGhostSequence(stepSize: Float = 1/8, clear: Bool = true) {
        if (clear) { sequence.tracks[Sequence.SnareDrumGhost.rawValue].clear() }
        let numberOfSteps = Int(Float(sequenceLength.value)/stepSize)
        //print("steps in sequnce: \(numberOfSteps)")
        for i in 0 ..< numberOfSteps {
            if(arc4random_uniform(17) > 14) {
                let step = Double(i) * stepSize
                sequence.tracks[Sequence.SnareDrumGhost.rawValue].add(noteNumber: 60,
                                       velocity: Int(arc4random_uniform(65) + 1),
                                       position: Beat(step),
                                       duration: Beat(0.1))
            }
        }
        sequence.setLength(sequenceLength)
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
    
    func clear(typeOfSequence: Sequence) {
        sequence.tracks[typeOfSequence.rawValue].clear()
    }
    
    func increaseTempo() {
        currentTempo += 1.0
        sequence.setTempo(currentTempo)
    }
    
    func decreaseTempo() {
        currentTempo -= 1.0
        sequence.setTempo(currentTempo)
    }
}
