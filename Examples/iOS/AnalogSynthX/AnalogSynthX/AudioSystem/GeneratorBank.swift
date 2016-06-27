//
//  GeneratorBank.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka on 6/25/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class GeneratorBank: AKPolyphonicNode {
    
    func updateWaveform1() {
        var newWaveformIndex = waveform1 + morph
        if newWaveformIndex < 0 { newWaveformIndex = 0 }
        if newWaveformIndex > 3 { newWaveformIndex = 3 }
        vco1.index = newWaveformIndex
    }
    
    func updateWaveform2() {
        var newWaveformIndex = waveform2 + morph
        if newWaveformIndex < 0 { newWaveformIndex = 0 }
        if newWaveformIndex > 3 { newWaveformIndex = 3 }
        vco2.index = newWaveformIndex
    }
    
    var waveform1 = 0.0 { didSet { updateWaveform1() } }
    var waveform2 = 0.0 { didSet { updateWaveform2() } }
    
    var globalbend: Double = 0.0 {
        didSet {
//            for i in 0..<activeVoices.count {
//                let coreVoice = activeVoices[i] as! CoreVoice
//                let note = Double(activeNotes[i] + offset1) + globalbend
//                coreVoice.vco1.frequency = note.midiNoteToFrequency()
//                let note2 = Double(activeNotes[i] + offset2) + globalbend
//                coreVoice.vco2.frequency = note2.midiNoteToFrequency()
//                coreVoice.subOsc.frequency = (Double(activeNotes[i] - 12) + globalbend).midiNoteToFrequency()
//            }
        }
    }
    
    var offset1 = 0 {
        willSet {
            for note in onNotes {
                vco1.stop(note: note + offset1)
                vco1.play(note: note + newValue, velocity: 127)
            }
        }
    }
    
    var offset2 = 0 {
        willSet {
            for note in onNotes {
                vco2.stop(note: note + offset2)
                vco2.play(note: note + newValue, velocity: 127)
            }
        }
    }
    
    
    var morph: Double = 0.0 {
        didSet {
            updateWaveform1()
            updateWaveform2()
        }
    }
    
    
    /// Attack time
    var attackDuration: Double = 0.1 {
        didSet {
            if attackDuration < 0.02 { attackDuration = 0.02 }
            vco1.attackDuration = attackDuration
            vco2.attackDuration = attackDuration
            subOsc.attackDuration = attackDuration
            fmOsc.attackDuration = attackDuration
            
        }
    }
    /// Decay time
    var decayDuration: Double = 0.1 {
        didSet {
//            if decayDuration < 0.02 { decayDuration = 0.02 }
//            vco1.decayDuration = decayDuration
//            vco2.decayDuration = decayDuration
//            subOsc.decayDuration = decayDuration
//            fmOsc.decayDuration = decayDuration
            
        }
    }
    /// Sustain Level
    var sustainLevel: Double = 0.66 {
        didSet {
//            adsr.sustainLevel = sustainLevel
        }
    }
    
    /// Release time
    var releaseDuration: Double = 0.5 {
        didSet {
            if releaseDuration < 0.02 { releaseDuration = 0.02 }
            vco1.releaseDuration = releaseDuration
            vco2.releaseDuration = releaseDuration
            subOsc.releaseDuration = releaseDuration
            fmOsc.releaseDuration = releaseDuration
        }
    }
    
    var vco1On = true {
        didSet {
            vco1Mixer.volume  = vco1On ? 1.0 : 0.0
        }
    }
    
    var vco2On = true {
        didSet {
            vco2Mixer.volume = vco2On ? 1.0 : 0.0
        }
    }
    
    var vco1: AKMorphingOscillatorBank
    var vco2: AKMorphingOscillatorBank
    var subOsc = AKOscillatorBank()
    var fmOsc  = AKFMOscillatorBank()
    var noise  = AKWhiteNoise()
    
    // We'll be using these simply to control volume independent of velocity
    var vco1Mixer: AKMixer
    var vco2Mixer: AKMixer
    var subOscMixer: AKMixer
    var fmOscMixer: AKMixer
    var noiseMixer: AKMixer
    
    var vcoBalancer: AKDryWetMixer
    var sourceMixer: AKMixer
    
    var onNotes = Set<Int>()
    
    override init() {
        let triangle = AKTable(.Triangle)
        let square   = AKTable(.Square)
        let sawtooth = AKTable(.Sawtooth)
        var squareWithHighPWM = AKTable()
        let size = squareWithHighPWM.values.count
        for i in 0..<size {
            if i < size / 8 {
                squareWithHighPWM.values[i] = -1.0
            } else {
                squareWithHighPWM.values[i] = 1.0
            }
        }
        vco1 = AKMorphingOscillatorBank(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])
        vco2 = AKMorphingOscillatorBank(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])
        
        vco1Mixer   = AKMixer(vco1)
        vco2Mixer   = AKMixer(vco2)
        subOscMixer = AKMixer(subOsc)
        fmOscMixer  = AKMixer(fmOsc)
        noiseMixer  = AKMixer(noise)
        
        // Default non-VCO's off
        subOscMixer.volume = 0
        fmOscMixer.volume  = 0
        noiseMixer.volume  = 0
        
        vcoBalancer = AKDryWetMixer(vco1Mixer, vco2Mixer, balance: 0.5)
        
        sourceMixer = AKMixer(vcoBalancer, fmOscMixer, subOscMixer, noiseMixer)
        
        super.init()
        
        avAudioNode = sourceMixer.avAudioNode
    }
    
    
    /// Function to start, play, or activate the node, all do the same thing
    override func play(note note: Int, velocity: Int) {
        
        vco1.play(note: note + offset1, velocity: velocity)
        vco2.play(note: note + offset2, velocity: velocity)
        subOsc.play(note: note, velocity: velocity)
        fmOsc.play(note: note, velocity: velocity)
        if onNotes.count == 0 {
            noise.start()
        }
        onNotes.insert(note)
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop(note note: Int) {
        vco1.stop(note: note)
        vco2.stop(note: note)
        subOsc.stop(note: note)
        fmOsc.stop(note: note)
        onNotes.remove(note)
        if onNotes.count == 0 {
            noise.stop()
        }
    }
}