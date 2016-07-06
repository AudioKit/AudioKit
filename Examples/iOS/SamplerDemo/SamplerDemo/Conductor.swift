//
//  Conductor.swift
//  SamplerDemo
//
//  Created by Jeff Cooper and Kanstantsin Linou on 7/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    private var sequence: AKSequencer?
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
        mixer.connect(arpeggioVolume!)
        mixer.connect(padVolume!)
        mixer.connect(bassVolume!)
        mixer.connect(drumKitVolume!)
        
        filter = AKMoogLadder(mixer)
        filter?.cutoffFrequency = 20000
        AudioKit.output = filter

        arpeggioSynthesizer.loadEXS24("Sounds/Sampler Instruments/sqrTone1")
        padSynthesizer.loadEXS24("Sounds/Sampler Instruments/sawPiano1")
        bassSynthesizer.loadEXS24("Sounds/Sampler Instruments/sawPad1")
        drumKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        AudioKit.start()
        sequence = AKSequencer(filename: "seqDemo", engine: AudioKit.engine)
        sequence?.enableLooping()
        sequence!.avTracks[1].destinationAudioUnit = arpeggioSynthesizer.samplerUnit
        sequence!.avTracks[2].destinationAudioUnit = padSynthesizer.samplerUnit
        sequence!.avTracks[3].destinationAudioUnit = bassSynthesizer.samplerUnit
        sequence!.avTracks[4].destinationAudioUnit = drumKit.samplerUnit
        sequence!.setLength(Beat(4))
    }
    
    func adjustVolume(volume: Float, instrument: Instrument) {
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
    
    func adjustFilterFrequency(frequency: Float) {
        var value = Double(frequency)
        value.denormalize(Double(30.0), max: Double(20000.00), taper: 3.03)
        filter?.cutoffFrequency = value
    }
    
    func playSequence() {
        sequence!.play()
    }
    
    func stopSequence() {
        sequence!.stop()
    }
    
    func rewindSequence() {
        sequence!.rewind()
    }
    
    func setLength(length: Double) {
        sequence!.setLength(Beat(length))
        sequence!.rewind()
    }
    
    func useSound(sound: Sound, synthesizer: Synthesizer) {
        let soundPath: String?
        switch sound {
        case Sound.Square:
            soundPath = "Sounds/Sampler Instruments/sqrTone1"
        case Sound.Piano:
            soundPath = "Sounds/Sampler Instruments/sawPiano1"
        case Sound.Saw:
            soundPath = "Sounds/Sampler Instruments/sawPad1"
        case Sound.Noise:
            soundPath = "Sounds/Sampler Instruments/noisyRez"
        }
        
        guard let path = soundPath else {
            print("Type of sound wasn't detected")
            return
        }
        
        switch synthesizer {
        case Synthesizer.Arpeggio:
            arpeggioSynthesizer.loadEXS24(path)
        case Synthesizer.Pad:
            padSynthesizer.loadEXS24(path)
        case Synthesizer.Bass:
            bassSynthesizer.loadEXS24(path)
        }
    }
}