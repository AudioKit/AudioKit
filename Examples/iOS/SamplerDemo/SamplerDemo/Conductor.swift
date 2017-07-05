//
//  Conductor.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou on 7/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

enum Synthesizer {
    case Arpeggio, Pad, Bass
}

enum Instrument {
    case Arpeggio, Pad, Bass, Drum
}

enum Sound: String {
    case Square
    case Saw
    case SlowPad
    case Noisy
}

class Conductor {
    private var sequencer: AKSequencer!
    private var mixer = AKMixer()
    private var arpeggioSynthesizer = AKMIDISampler()
    private var padSynthesizer = AKMIDISampler()
    private var bassSynthesizer = AKMIDISampler()
    private var drumKit = AKMIDISampler()
    private var filter: AKMoogLadder?

    init() {
        arpeggioSynthesizer.enableMIDI(AKMIDI().client, name: "arp")
        padSynthesizer.enableMIDI(AKMIDI().client, name: "pad")
        bassSynthesizer.enableMIDI(AKMIDI().client, name: "bass")
        drumKit.enableMIDI(AKMIDI().client, name: "drums")
        mixer.connect(arpeggioSynthesizer)
        mixer.connect(padSynthesizer)
        mixer.connect(bassSynthesizer)
        mixer.connect(drumKit)

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
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        sequencer.tracks[2].setMIDIOutput(bassSynthesizer.midiIn)
        sequencer.tracks[3].setMIDIOutput(padSynthesizer.midiIn)
        sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)
//        sequencer.setLength(AKDuration(beats: 4))
        sequencer.play()
    }

    func adjustVolume(_ volume: Double, instrument: Instrument) {
        switch instrument {
        case .Arpeggio:
            arpeggioSynthesizer.volume = volume
        case .Pad:
            padSynthesizer.volume = volume
        case .Bass:
            bassSynthesizer.volume = volume
        case .Drum:
            drumKit.volume = volume
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
        AKLog("Settign Length \(length)")
        sequencer.setLength(AKDuration(beats: length))
        sequencer.rewind()
    }

    func useSound(_ sound: Sound, synthesizer: Synthesizer) {
        let soundPath: String?
        switch sound {
        case .Square:
            soundPath = "Sounds/Sampler Instruments/sqrTone1"
        case .Saw:
            soundPath = "Sounds/Sampler Instruments/sawPiano1"
        case .SlowPad:
            soundPath = "Sounds/Sampler Instruments/sawPad1"
        case .Noisy:
            soundPath = "Sounds/Sampler Instruments/noisyRez"
        }

        guard let path = soundPath else {
            print("Type of sound wasn't detected")
            return
        }

        do {
            switch synthesizer {
            case .Arpeggio:
                try arpeggioSynthesizer.loadEXS24(path)
            case .Pad:
                try padSynthesizer.loadEXS24(path)
            case .Bass:
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
