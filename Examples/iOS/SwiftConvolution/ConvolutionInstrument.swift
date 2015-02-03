//
//  ConvolutionInstrument.swift
//  SwiftConvolution
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

class ConvolutionInstrument: AKInstrument
{
    // INPUTS AND CONTROLS =====================================================
    
    var dishWellBalance = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1.0)
    var dryWetBalance   = AKInstrumentProperty(value: 0, minimum: 0, maximum: 0.1)
    
    // INSTRUMENT DEFINITION ===================================================
    override init() {
        super.init()
        
        addProperty(dishWellBalance)
        addProperty(dryWetBalance)
        
        let file = String(NSBundle.mainBundle().pathForResource("808loop", ofType: "wav")!)
        let loop = AKFileInput(filename: file)
        connect(loop)
        
        let dish = String(NSBundle.mainBundle().pathForResource("dish", ofType: "wav")!)
        let well = String(NSBundle.mainBundle().pathForResource("Stairwell", ofType: "wav")!)
        
        let dishConv = AKConvolution(input: loop.leftOutput, impulseResponseFilename: dish)
        connect(dishConv)

        let wellConv = AKConvolution(input: loop.rightOutput, impulseResponseFilename: well)
        connect(wellConv)

        let balance = AKMix(input1: dishConv, input2: wellConv, balance: dishWellBalance)
        connect(balance)
        
        let dryWet = AKMix(input1: loop.leftOutput, input2: balance, balance: dryWetBalance)
        connect(dryWet)
    
        connect(AKAudioOutput(audioSource: dryWet))
    }
}