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
    
    var averageGrainDuration        = AKInstrumentProperty(value: 0.25, minimum: 0.1,  maximum: 0.4)
    var grainDensity                = AKInstrumentProperty(value: 300,  minimum: 10,   maximum: 600)
    var granularFrequencyDeviation  = AKInstrumentProperty(value: 0.05, minimum: 0,    maximum: 0.1)
    var granularAmplitude           = AKInstrumentProperty(value: 0.1,  minimum: 0.01, maximum: 0.2)
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        addProperty(averageGrainDuration)
        addProperty(grainDensity)
        addProperty(granularFrequencyDeviation)
        addProperty(granularAmplitude)
        
        let file = String (NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")!)
        
        let fileTable = AKSoundFile(filename: file)
        fileTable.size = 16384
        connect(fileTable)
        
        let hamming = AKWindow(type: AKWindowTableType.Hamming)
        hamming.size = 512;
        connect(hamming)
        
        let baseFrequency = AKConstant(expression: String(format: "44100 / %@", fileTable.length()))
        
        let grainTexture =  AKGranularSynthesisTexture(
            grainFunctionTable: fileTable,
            windowFunctionTable: hamming
        )
        grainTexture.averageGrainDuration = averageGrainDuration
        grainTexture.maximumFrequencyDeviation = granularFrequencyDeviation
        grainTexture.grainFrequency = baseFrequency
        grainTexture.grainAmplitude = granularAmplitude
        grainTexture.grainDensity = grainDensity
        connect(grainTexture)
        
        connect(AKAudioOutput(audioSource: grainTexture))
    }
}