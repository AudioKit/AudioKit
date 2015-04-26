//
//  ConvolutionInstrument.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class ConvolutionInstrument: AKInstrument
    
{
    // INPUTS AND CONTROLS =====================================================
    
    var dishWellBalance = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1.0)
    var dryWetBalance   = AKInstrumentProperty(value: 0, minimum: 0, maximum: 0.1)
    
    // INSTRUMENT DEFINITION ===================================================
    init(input: AKAudio) {
        super.init()
        
        addProperty(dishWellBalance)
        addProperty(dryWetBalance)
        
        let dish = AKManager.pathToSoundFile("dish", ofType: "wav")
        let well = AKManager.pathToSoundFile("Stairwell", ofType: "wav")
        
        let dishConv = AKConvolution(input: input, impulseResponseFilename: dish!)
        
        let wellConv = AKConvolution(input: input, impulseResponseFilename: well!)
        
        let balance = AKMix(input1: dishConv, input2: wellConv, balance: dishWellBalance)
        
        let dryWet = AKMix(input1: input, input2: balance, balance: dryWetBalance)
        
        // AUDIO OUTPUT ========================================================
        setAudioOutput(dryWet)
        
        // EXTERNAL OUTPUTS ====================================================
        let auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: dryWet)
        
        resetParameter(input)
    }
}