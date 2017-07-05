//
//  Conductor.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou on 7/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    private var sequencer: AKSequencer!
    private var mixer = AKMixer()
    private var arpeggioSynthesizer = AKSampler()
    private var padSynthesizer = AKSampler()
    private var bassSynthesizer = AKSampler()
    private var drumKit = AKSampler()
    private var arpeggioVolume: AKBooster?
    private var padVolume: AKBooster?
    private var bassVolume: AKBooster?
    private var drumKitVolume: AKBooster?
    private var filter: AKMoogLadder?

    init() {
        arpeggioVolume = AKBooster(arpeggioSynthesizer)
        padVolume = AKBooster(padSynthesizer)
        bassVolume = AKBooster(bassSynthesizer)
        drumKitVolume = AKBooster(drumKit)
        arpeggioVolume?.gain = 1
        padVolume?.gain = 1
        bassVolume?.gain = 1
        drumKitVolume?.gain = 1
        mixer.connect(arpeggioVolume)
        mixer.connect(padVolume)
        mixer.connect(bassVolume)
        mixer.connect(drumKitVolume)

        filter = AKMoogLadder(mixer)
        filter?.cutoffFrequency = 20_000
        AudioKit.output = filter

        do {
            try arpeggioSynthesizer.loadEXS24("Sounds/Sampler Instruments/sqrTone1")
            try padSynthesizer.loadEXS24("Sounds/Sampler Instruments/sawPad1")
            try bassSynthesizer.loadEXS24("Sounds/Sampler Instruments/sawPiano1")
            try drumKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        } catch {
            print("A file was not found.")
        }
        AudioKit.start()

        sequencer = AKSequencer(filename: "seqDemo")
        sequencer.enableLooping()
        sequencer.tracks[1].destinationAudioUnit = arpeggioSynthesizer.samplerUnit
        sequencer.tracks[2].destinationAudioUnit = bassSynthesizer.samplerUnit
        sequencer.tracks[3].destinationAudioUnit = padSynthesizer.samplerUnit
        sequencer.tracks[4].destinationAudioUnit = drumKit.samplerUnit
        sequencer.setLength(AKDuration(beats: 4))
        sequencer.play()
    }

    func adjustVolume(_ volume: Float, instrument: Instrument) {
        switch instrument {
        case Instrument.Arpeggio:
            arpeggioVolume?.gain = Double(volume)
        case Instrument.Pad:
            padVolume?.gain = Double(volume)
        case Instrument.Bass:
            bassVolume?.gain = Double(volume)
        case Instrument.Drum:
            drumKitVolume?.gain = Double(volume)
        }
    }

    func adjustFilterFrequency(_ frequency: Float) {
        let value = Double(frequency)
        filter?.cutoffFrequency = value.denormalized(minimum: 30, maximum: 20_000, taper: 3)
    }

    func playSequence() {
        sequencer.play()
    }

    func stopSequence() {
        sequencer.stop()
    }

    func rewindSequence() {
        sequencer.rewind()
    }

    func setLength(_ length: Double) {
        sequencer.setLength(AKDuration(beats: length))
        sequencer.rewind()
    }

    func useSound(_ sound: Sound, synthesizer: Synthesizer) {
        let soundPath: String?
        switch sound {
        case Sound.Square:
            soundPath = "Sounds/Sampler Instruments/sqrTone1"
        case Sound.Saw:
            soundPath = "Sounds/Sampler Instruments/sawPiano1"
        case Sound.SlowPad:
            soundPath = "Sounds/Sampler Instruments/sawPad1"
        case Sound.Noisy:
            soundPath = "Sounds/Sampler Instruments/noisyRez"
        }

        guard let path = soundPath else {
            print("Type of sound wasn't detected")
            return
        }

        do {
            switch synthesizer {
            case Synthesizer.Arpeggio:
                try arpeggioSynthesizer.loadEXS24(path)
            case Synthesizer.Pad:
                try padSynthesizer.loadEXS24(path)
            case Synthesizer.Bass:
                try bassSynthesizer.loadEXS24(path)
            }
        } catch {
            print("Could not load EXS24")
        }
    }

    func adjustTempo(_ tempo: Float) {
        sequencer?.setRate(Double(tempo))
    }
}
