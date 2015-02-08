//
//  GranularSynth.swift
//  SwiftGranularSynthTest
//
//  Created by Nicholas Arner on 9/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

class GranularSynth: AKInstrument
{
    // INSTRUMENT CONTROLS =====================================================
    
    var mix = AKInstrumentProperty(
        value:    0.5,
        minimum:  0,
        maximum:  1
    )
    var frequency = AKInstrumentProperty(
        value:    0.2,
        minimum:  0.01,
        maximum:  10
    )
    var duration = AKInstrumentProperty(
        value:    10,
        minimum:   0.1,
        maximum:  20
    )
    var density = AKInstrumentProperty(
        value:    1,
        minimum:  0.1,
        maximum:  2
    )
    var frequencyVariation = AKInstrumentProperty(
        value:    10,
        minimum:   0.1,
        maximum:  20
    )
    var frequencyVariationDistribution = AKInstrumentProperty(
        value:    10,
        minimum:   0.1,
        maximum:  20
    )
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        addProperty(mix)
        addProperty(frequency)
        addProperty(duration)
        addProperty(density)
        addProperty(frequencyVariation)
        addProperty(frequencyVariationDistribution)
        
        let file = String (NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")!)
        
        let soundFile = AKSoundFile(filename: file)
        soundFile.size = 16384
        addFunctionTable(soundFile)
        
        let synth =  AKGranularSynthesizer(
            grainWaveform: soundFile,
            frequency: frequency
        )
        synth.duration = duration
        synth.density = density
        synth.frequencyVariation = frequencyVariation
        synth.frequencyVariationDistribution = frequencyVariationDistribution
        connect(synth)
        
        let file2 = String (NSBundle.mainBundle().pathForResource("808loop", ofType: "wav")!)
        
        let soundFile2 = AKSoundFile(filename: file2)
        soundFile2.size = 16384
        addFunctionTable(soundFile2)
        
        let synth2 =  AKGranularSynthesizer(
            grainWaveform: soundFile2,
            frequency: frequency
        )
        synth2.duration = duration
        synth2.density = density
        synth2.frequencyVariation = frequencyVariation
        synth2.frequencyVariationDistribution = frequencyVariationDistribution
        connect(synth2)
        
        let mixer = AKMix(input1: synth, input2: synth2, balance: mix)
        connect(mixer)
        
        connect(AKAudioOutput(audioSource: mixer.scaledBy(0.5.ak)))
    }
}