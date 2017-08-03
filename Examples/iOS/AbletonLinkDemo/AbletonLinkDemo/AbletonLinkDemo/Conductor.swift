//
//  Conductor.swift
//  AbletonLinkDemo
//
//  Created by Joshua Thompson on 7/15/17.
//  Copyright © 2017 Joshua Thompson. All rights reserved.
//

import AudioKit
//import ABLink

class Conductor {
    let midi = AKMIDI()
    var view_controller: ViewController!
    var mixer = AKMixer()
    var bassDrum = AKSynthKick()
    var sequence = AKSequencer()
    var _linkSettings: UIViewController!
    var _quanta: Double = 4.0 //time sig
    var currentTempo = 120.0 {
        didSet {
            sequence.setTempo(currentTempo)
        }
    }
    
    let sequenceLength = AKDuration(beats: 8.0)
    
    init(vc: ViewController) {
        /* TODO: Setup ABLink...*/
        
        initSequence()
    }
    
    func initSequence(){
        bassDrum.enableMIDI(midi.client, name: "bassDrum midi in")
        mixer.connect(bassDrum)
        AudioKit.output = mixer
        AudioKit.start()
    }
    
    func setupTracks() {
        let _ = sequence.newTrack()
        sequence.setLength(sequenceLength)
        sequence.tracks[0].setMIDIOutput(bassDrum.midiIn)
        generateSequence()
        
        sequence.enableLooping()
        sequence.setTempo(120)
        sequence.play()
    }
    
    
    func generateSequence(_ stepSize: Float = 1, clear: Bool = true) {
        if clear { sequence.tracks[0].clear() }
        let numberOfSteps = Int(Float(sequenceLength.beats) / stepSize)
        for i in 0 ..< numberOfSteps {
            let step = Double(i) * stepSize
            
            sequence.tracks[0].add(noteNumber: 60,
                                                velocity: 100,
                                                position: AKDuration(beats: step),
                                                duration: AKDuration(beats: 1))
        }
    }
    
    
}
