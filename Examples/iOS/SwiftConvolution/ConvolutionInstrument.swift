//
//  ConvolutionInstrument.swift
//  SwiftConvolution
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
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
        
        let dishConv = AKConvolution(audioSource: loop.leftOutput, impulseResponseFile: dish)
        connect(dishConv)

        let wellConv = AKConvolution(audioSource: loop.rightOutput, impulseResponseFile: well)
        connect(wellConv)

        let balance = AKMixedAudio(signal1: dishConv, signal2: wellConv, balance: dishWellBalance)
        connect(balance)
        
        let dryWet = AKMixedAudio(signal1: loop.leftOutput, signal2: balance, balance: dryWetBalance)
        connect(dryWet)
    
        connect(AKAudioOutput(audioSource: dryWet))
    }
}