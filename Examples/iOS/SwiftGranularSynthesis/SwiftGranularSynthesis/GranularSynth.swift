//
//  GranularSynth.swift
//  SwiftGranularSynthTest
//
//  Created by Nicholas Arner on 9/30/14.
//  Copyright (c) 2014 Nicholas Arner. All rights reserved.
//


class GranularSynth: AKInstrument
    
{
    // INSTRUMENT CONTROLS =====================================================
    
    var averageGrainDuration        = AKInstrumentProperty(value: 0.05, minimum: 0.001, maximum: 0.05)
    var grainDensity                = AKInstrumentProperty(value: 25,   minimum: 0,     maximum: 2000)
    var granularFrequencyDeviation  = AKInstrumentProperty(value: 1500, minimum: 1,     maximum: 3000)
    var granularAmplitude           = AKInstrumentProperty(value: 1,    minimum: 0,     maximum: 2)
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        addProperty(averageGrainDuration)
        addProperty(grainDensity)
        addProperty(granularFrequencyDeviation)
        addProperty(granularAmplitude)
        
        let file = String (NSBundle .mainBundle() .pathForResource("PianoBassDrumLoop", ofType: "wav")!)

        let fileTable = AKSoundFileTable (filename: file, tableSize: 16384)
        connect(fileTable)

        let hamming = AKWindowsTable (type: kWindowHamming, size: 512)
        connect(hamming)

        let baseFrequency = AKConstant(expression: String(format: "44100 / %@", fileTable.length()))
        
        let grainTexture =  AKGranularSynthesisTexture (grainFTable: fileTable,
                                                        windowFTable: hamming,
                                                        maximumGrainDuration: AKConstant(float: 0.05),
                                                        averageGrainDuration: averageGrainDuration,
                                                        maximumFrequencyDeviation: granularFrequencyDeviation,
                                                        grainFrequency: baseFrequency,
                                                        maximumAmplitudeDeviation: AKConstant(float: 0.05),
                                                        grainAmplitude: granularAmplitude,
                                                        grainDensity: grainDensity)
        
        connect(grainTexture)
        connect(AKAudioOutput(audioSource: grainTexture))
    }
}