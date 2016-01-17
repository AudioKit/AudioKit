//
//  AKCoreInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

enum VCOWaveform {
    case Sawtooth, Square, Sine, Triangle
    
    mutating func changeWaveformFromIndex(index: Int) {
        switch index {
        case 0: self = .Sawtooth
        case 1: self = .Square
        case 2: self = .Sine
        case 3: self = .Triangle
        default: break
        }
    }
}

/// A wrapper for AKCore to make it a playable as a polyphonic instrument.
class CoreInstrument: AKPolyphonicInstrument {
    
    var offset1 = 0 {
        didSet {
            for i in 0..<activeVoices.count {
                let coreVoice = activeVoices[i] as! CoreVoice
                let note = activeNotes[i] + offset1
                coreVoice.sineVCO1.frequency     = note.midiNoteToFrequency()
                coreVoice.sawtoothVCO1.frequency = note.midiNoteToFrequency()
                coreVoice.squareVCO1.frequency   = note.midiNoteToFrequency()
                coreVoice.triangleVCO1.frequency = note.midiNoteToFrequency()
            }
        }
    }
    
    var offset2 = 0 {
        didSet {
            for i in 0..<activeVoices.count {
                let coreVoice = activeVoices[i] as! CoreVoice
                let note = activeNotes[i] + offset2
                coreVoice.sineVCO2.frequency     = note.midiNoteToFrequency()
                coreVoice.sawtoothVCO2.frequency = note.midiNoteToFrequency()
                coreVoice.squareVCO2.frequency   = note.midiNoteToFrequency()
                coreVoice.triangleVCO2.frequency = note.midiNoteToFrequency()
            }
        }
    }
    
    
    var subOscMix = 0.0 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.subOscMixer.volume = subOscMix
            }
        }
    }
    
    var fmOscMix = 0.0 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.fmOscMixer.volume = fmOscMix
            }
        }
    }
    
    var noiseMix = 0.0 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.noiseMixer.volume = noiseMix
            }
        }
    }
    
    var detune: Double = 0.0 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.sawtoothVCO2.detuningOffset = detune
                coreVoice.sineVCO2.detuningOffset     = detune
                coreVoice.squareVCO2.detuningOffset   = detune
                coreVoice.triangleVCO2.detuningOffset = detune
            }
        }
    }
    
    var fmMod: Double = 1 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                // coreVoice.fmOscillator.modulatingMultiplier = 1 + fmMod / 4
                coreVoice.fmOscillator.carrierMultiplier = 1 + (fmMod / 2)
                coreVoice.fmOscillator.modulationIndex = fmMod
            }
        }
    }
    
    var vco12Mix: Double = 0.5 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.vco12Mixer.balance = vco12Mix
            }
        }
    }
    
    var pulseWidth: Double = 0.5 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.squareVCO1.pulseWidth = pulseWidth
                coreVoice.squareVCO2.pulseWidth = pulseWidth
            }
        }
    }
    
    /// Attack time
    var attackDuration: Double = 0.1 {
        didSet {
            if attackDuration < 0.02 { attackDuration = 0.02 }
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    var decayDuration: Double = 0.1 {
        didSet {
            if decayDuration < 0.02 { decayDuration = 0.02 }
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    
    /// Release time
    var releaseDuration: Double = 0.5 {
        didSet {
            if releaseDuration < 0.02 { releaseDuration = 0.02 }
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    func updateVCO1() {
        for voice in voices {
            let coreVoice = voice as! CoreVoice
            
            coreVoice.sawtoothVCO1.stop()
            coreVoice.squareVCO1.stop()
            coreVoice.sineVCO1.stop()
            coreVoice.triangleVCO1.stop()
            
            if vco1On {
                switch selectedVCO1Waveform {
                case .Sawtooth:
                    coreVoice.sawtoothVCO1.start()
                case .Square:
                    coreVoice.squareVCO1.start()
                case .Sine:
                    coreVoice.sineVCO1.start()
                case .Triangle:
                    coreVoice.triangleVCO1.start()
                }
            }
        }
    }
    
    func updateVCO2() {
        for voice in voices {
            let coreVoice = voice as! CoreVoice
            
            coreVoice.sawtoothVCO2.stop()
            coreVoice.squareVCO2.stop()
            coreVoice.sineVCO2.stop()
            coreVoice.triangleVCO2.stop()
            
            if vco2On {
                switch selectedVCO2Waveform {
                case .Sawtooth:
                    coreVoice.sawtoothVCO2.start()
                case .Square:
                    coreVoice.squareVCO2.start()
                case .Sine:
                    coreVoice.sineVCO2.start()
                case .Triangle:
                    coreVoice.triangleVCO2.start()
                }
            }
            
        }
    }
    var selectedVCO1Waveform = VCOWaveform.Sawtooth { didSet { updateVCO1() } }
    var selectedVCO2Waveform = VCOWaveform.Sawtooth { didSet { updateVCO2() } }
    var vco1On = true { didSet { updateVCO1() } }
    var vco2On = true { didSet { updateVCO2() } }
    
    
    /// Instantiate the Instrument
    ///
    /// - parameter voiceCount: Maximum number of voices that will be required
    ///
    init(voiceCount: Int) {
        super.init(voice: CoreVoice(), voiceCount: voiceCount)
        
        let sourceCount = 11
        amplitude = 1.0 /  Double(sourceCount * voiceCount)
        
    }
    
    /// Start a given voice playing a note.
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number to start
    /// - parameter velocity: MIDI Velocity (0-127) to trigger the note at
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let coreVoice = voice as! CoreVoice
        
        let commonAmplitude = Double(velocity)/127.0
        
        coreVoice.sawtoothVCO1.amplitude = commonAmplitude
        coreVoice.squareVCO1.amplitude   = commonAmplitude
        coreVoice.sineVCO1.amplitude     = commonAmplitude
        coreVoice.triangleVCO1.amplitude = commonAmplitude
        
        
        coreVoice.sawtoothVCO2.amplitude = commonAmplitude
        coreVoice.squareVCO2.amplitude   = commonAmplitude
        coreVoice.sineVCO2.amplitude     = commonAmplitude
        coreVoice.triangleVCO2.amplitude = commonAmplitude
        
        coreVoice.subOsc.amplitude       = commonAmplitude
        coreVoice.fmOscillator.amplitude = commonAmplitude
        coreVoice.noise.amplitude        = commonAmplitude
        
        let vco1Frequency = (note + offset1).midiNoteToFrequency()
        
        coreVoice.sawtoothVCO1.frequency = vco1Frequency
        coreVoice.sineVCO1.frequency     = vco1Frequency
        coreVoice.squareVCO1.frequency   = vco1Frequency
        coreVoice.triangleVCO1.frequency = vco1Frequency
        
        let vco2Frequency = (note + offset2).midiNoteToFrequency()
        
        coreVoice.sawtoothVCO2.frequency = vco2Frequency
        coreVoice.sineVCO2.frequency     = vco2Frequency
        coreVoice.squareVCO2.frequency   = vco2Frequency
        coreVoice.triangleVCO2.frequency = vco2Frequency
        
        coreVoice.subOsc.frequency = (note - 12).midiNoteToFrequency()
        coreVoice.fmOscillator.baseFrequency = note.midiNoteToFrequency()
        
        
        // Intelligently start only what we need to:
        updateVCO1()
        updateVCO2()
        coreVoice.start()
    }
    
    /// Stop a given voice playing a note.
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number to stop
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        let coreVoice = voice as! CoreVoice
        coreVoice.stop()
    }
    
}

