//
//  AKCoreInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit



/// A wrapper for AKCore to make it a playable as a polyphonic instrument.
class CoreInstrument: AKPolyphonicInstrument {
    
    var offset1 = 0 // semitones, from a the knob
    var offset2 = 7 // semitones, presumably we'll get from a knob
    var detune = -50.0 // Hz, again, presumably from a knob
    var subOscMix = 0.0
    var fmOscMix = 0.0
    var noiseMix = 0.0
    
    var fmMod: Double = 1 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                // Matt Fecher: Do what you'd like to do with this value, I have no clue
//                coreVoice.fmOscillator.carrierMultiplier = carrierMultiplier
//                coreVoice.fmOscillator.modulatingMultiplier = modulatingMultiplier
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
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    var decayDuration: Double = 0.1 {
        didSet {
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
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
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
    override func playVoice(voice: Int, note: Int, velocity: Int) {
        let coreVoice = voices[voice] as! CoreVoice
        
        let commonAmplitude = Double(velocity)/127.0
        
        coreVoice.sawtoothVCO1.amplitude = commonAmplitude
        coreVoice.sineVCO1.amplitude     = commonAmplitude
        coreVoice.squareVCO1.amplitude   = commonAmplitude
        coreVoice.triangleVCO1.amplitude = commonAmplitude
        coreVoice.sawtoothVCO2.amplitude = commonAmplitude
        coreVoice.sineVCO2.amplitude     = commonAmplitude
        coreVoice.squareVCO2.amplitude   = commonAmplitude
        coreVoice.triangleVCO2.amplitude = commonAmplitude
        
        coreVoice.subOsc.amplitude       = commonAmplitude * subOscMix
        coreVoice.fmOscillator.amplitude = commonAmplitude * fmOscMix
        coreVoice.noise.amplitude        = commonAmplitude * noiseMix
        
        let vco1Frequency = (note + offset1).midiNoteToFrequency()
        
        coreVoice.sawtoothVCO1.frequency = vco1Frequency
        coreVoice.sineVCO1.frequency     = vco1Frequency
        coreVoice.squareVCO1.frequency   = vco1Frequency
        coreVoice.triangleVCO1.frequency = vco1Frequency
        
        let vco2Frequency = (note + offset2).midiNoteToFrequency() + detune
    
        coreVoice.sawtoothVCO2.frequency = vco2Frequency
        coreVoice.sineVCO2.frequency     = vco2Frequency
        coreVoice.squareVCO2.frequency   = vco2Frequency
        coreVoice.triangleVCO2.frequency = vco2Frequency
        
        coreVoice.subOsc.frequency = (note - 12).midiNoteToFrequency()
        coreVoice.fmOscillator.baseFrequency = note.midiNoteToFrequency()
        
        coreVoice.start()
    }
    
    /// Stop a given voice playing a note.
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number to stop
    ///
    override func stopVoice(voice: Int, note: Int) {
        let coreVoice = voices[voice] as! CoreVoice
        coreVoice.stop()
    }
    
}

