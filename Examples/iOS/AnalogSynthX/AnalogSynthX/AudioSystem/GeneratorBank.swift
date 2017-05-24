//
//  GeneratorBank.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka on 6/25/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class GeneratorBank: AKPolyphonicNode {

    func updateWaveform1() {
        vco1.index = (0...3).clamp(waveform1 + morph)
    }

    func updateWaveform2() {
        vco2.index = (0...3).clamp(waveform2 + morph)
    }

    var waveform1 = 0.0 { didSet { updateWaveform1() } }
    var waveform2 = 0.0 { didSet { updateWaveform2() } }

    var globalbend: Double = 1.0 {
        didSet {
            vco1.detuningMultiplier = globalbend
            vco2.detuningMultiplier = globalbend
            subOsc.detuningMultiplier = globalbend
            fmOsc.detuningMultiplier = globalbend
        }
    }

    var offset1 = 0 {
        willSet {
            for noteNumber in onNotes {
                vco1.stop(noteNumber: MIDINoteNumber(Int(noteNumber) + offset1))
                vco1.play(noteNumber: MIDINoteNumber(Int(noteNumber) + newValue), velocity: 127)
            }
        }
    }

    var offset2 = 0 {
        willSet {
            for noteNumber in onNotes {
                vco2.stop(noteNumber: MIDINoteNumber(Int(noteNumber) + offset2))
                vco2.play(noteNumber: MIDINoteNumber(Int(noteNumber) + newValue), velocity: 127)
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
            noiseADSR.attackDuration = attackDuration

        }
    }

    /// Decay time
    var decayDuration: Double = 0.1 {
        didSet {
            if decayDuration < 0.02 { decayDuration = 0.02 }
            vco1.decayDuration = decayDuration
            vco2.decayDuration = decayDuration
            subOsc.decayDuration = decayDuration
            fmOsc.decayDuration = decayDuration
            noiseADSR.decayDuration = decayDuration
        }
    }

    /// Sustain Level
    var sustainLevel: Double = 0.66 {
        didSet {
            vco1.sustainLevel = sustainLevel
            vco2.sustainLevel = sustainLevel
            subOsc.sustainLevel = sustainLevel
            fmOsc.sustainLevel = sustainLevel
            noiseADSR.sustainLevel = sustainLevel
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
            noiseADSR.releaseDuration = releaseDuration
       }
    }

    var vco1On = true {
        didSet {
            vco1Mixer.volume = vco1On ? 1.0 : 0.0
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
    var fmOsc = AKFMOscillatorBank()
    var noise = AKWhiteNoise()
    var noiseADSR: AKAmplitudeEnvelope

    // We'll be using these simply to control volume independent of velocity
    var vco1Mixer: AKMixer
    var vco2Mixer: AKMixer
    var subOscMixer: AKMixer
    var fmOscMixer: AKMixer
    var noiseMixer: AKMixer

    var vcoBalancer: AKDryWetMixer
    var sourceMixer: AKMixer

    var onNotes = Set<MIDINoteNumber>()

    override init() {
        let triangle = AKTable(.triangle)
        let square = AKTable(.square)
        let sawtooth = AKTable(.sawtooth)

        var squareWithHighPWM = AKTable()
        let count = squareWithHighPWM.count
        for i in squareWithHighPWM.indices {
            if i < count / 8 {
                squareWithHighPWM[i] = -1.0
            } else {
                squareWithHighPWM[i] = 1.0
            }
        }
        vco1 = AKMorphingOscillatorBank(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])
        vco2 = AKMorphingOscillatorBank(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])

        noiseADSR = AKAmplitudeEnvelope(noise)

        vco1Mixer = AKMixer(vco1)
        vco2Mixer = AKMixer(vco2)
        subOscMixer = AKMixer(subOsc)
        fmOscMixer = AKMixer(fmOsc)
        noiseMixer = AKMixer(noiseADSR)

        // Default non-VCO's off
        subOscMixer.volume = 0
        fmOscMixer.volume = 0
        noiseMixer.volume = 0

        vcoBalancer = AKDryWetMixer(vco1Mixer, vco2Mixer, balance: 0.5)

        sourceMixer = AKMixer(vcoBalancer, fmOscMixer, subOscMixer, noiseMixer)

        super.init()

        avAudioNode = sourceMixer.avAudioNode
    }

    /// Function to start, play, or activate the node, all do the same thing
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

        vco1.play(noteNumber: MIDINoteNumber(Int(noteNumber) + offset1), velocity: velocity)
        vco2.play(noteNumber: MIDINoteNumber(Int(noteNumber) + offset2), velocity: velocity)
        if noteNumber >= 12 {
            subOsc.play(noteNumber: noteNumber - 12, velocity: velocity)
        }
        fmOsc.play(noteNumber: noteNumber, velocity: velocity)
        if onNotes.isEmpty {
            noise.start()
            noiseADSR.start()
        }
        onNotes.insert(noteNumber)
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop(noteNumber: MIDINoteNumber) {

        vco1.stop(noteNumber: MIDINoteNumber(Int(noteNumber) + offset1))
        vco2.stop(noteNumber: MIDINoteNumber(Int(noteNumber) + offset2))
        if noteNumber >= 12 {
            subOsc.stop(noteNumber: noteNumber - 12)
        }
        fmOsc.stop(noteNumber: noteNumber)
        onNotes.remove(noteNumber)
        if onNotes.isEmpty {
            noiseADSR.stop()
        }
    }
}
