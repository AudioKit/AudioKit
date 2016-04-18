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

    func updateWaveform1() {
        var newWaveformIndex = waveform1 + morph
        if newWaveformIndex < 0 { newWaveformIndex = 0 }
        if newWaveformIndex > 3 { newWaveformIndex = 3 }
        for voice in voices {
            let coreVoice = voice as! CoreVoice
            coreVoice.vco1.index = newWaveformIndex
        }
    }

    func updateWaveform2() {
        var newWaveformIndex = waveform2 + morph
        if newWaveformIndex < 0 { newWaveformIndex = 0 }
        if newWaveformIndex > 3 { newWaveformIndex = 3 }
        for voice in voices {
            let coreVoice = voice as! CoreVoice
            coreVoice.vco2.index = newWaveformIndex
        }
    }

    var waveform1 = 0.0 { didSet { updateWaveform1() } }
    var waveform2 = 0.0 { didSet { updateWaveform2() } }

    var globalbend: Double = 0.0 {
        didSet {
            for i in 0..<activeVoices.count {
                let coreVoice = activeVoices[i] as! CoreVoice
                let note = Double(activeNotes[i] + offset1) + globalbend
                coreVoice.vco1.frequency = note.midiNoteToFrequency()
                let note2 = Double(activeNotes[i] + offset2) + globalbend
                coreVoice.vco2.frequency = note2.midiNoteToFrequency()
                coreVoice.subOsc.frequency = (Double(activeNotes[i] - 12) + globalbend).midiNoteToFrequency()
            }
        }
    }

    var offset1 = 0 {
        didSet {
            for i in 0..<activeVoices.count {
                let coreVoice = activeVoices[i] as! CoreVoice
                let note = Double(activeNotes[i] + offset1) + globalbend
                coreVoice.vco1.frequency = note.midiNoteToFrequency()
            }
        }
    }

    var offset2 = 0 {
        didSet {
            for i in 0..<activeVoices.count {
                let coreVoice = activeVoices[i] as! CoreVoice
                let note = Double(activeNotes[i] + offset2) + globalbend
                coreVoice.vco2.frequency = note.midiNoteToFrequency()
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
                coreVoice.vco2.detuningOffset = detune
            }
        }
    }

    var fmMod: Double = 1 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.fmOsc.modulationIndex = fmMod
            }
        }
    }

    var vcoBalance: Double = 0.5 {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.vcoBalancer.balance = vcoBalance
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

    var vco1On = true {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.vco1Mixer.volume = vco1On ? 1.0 : 0.0
            }
        }
    }

    var vco2On = true {
        didSet {
            for voice in voices {
                let coreVoice = voice as! CoreVoice
                coreVoice.vco2Mixer.volume = vco2On ? 1.0 : 0.0
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
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let coreVoice = voice as! CoreVoice

        let commonAmplitude = Double(velocity)/127.0

        coreVoice.vco1.amplitude   = commonAmplitude
        coreVoice.vco2.amplitude   = commonAmplitude
        coreVoice.subOsc.amplitude = commonAmplitude
        coreVoice.fmOsc.amplitude  = commonAmplitude
        coreVoice.noise.amplitude  = commonAmplitude

        coreVoice.vco1.frequency = (Double(note + offset1) + globalbend).midiNoteToFrequency()
        coreVoice.vco2.frequency = (Double(note + offset2) + globalbend).midiNoteToFrequency()

        coreVoice.subOsc.frequency = (Double(note - 12) + globalbend).midiNoteToFrequency()
        coreVoice.fmOsc.baseFrequency = note.midiNoteToFrequency()

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
