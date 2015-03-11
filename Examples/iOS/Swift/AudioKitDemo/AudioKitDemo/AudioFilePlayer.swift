//
//  AudioFilePlayer.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


class AudioFilePlayer: AKInstrument {
    
    var auxilliaryOutput = AKAudio()

    // INSTRUMENT BASED CONTROL ============================================
    var speed       = AKInstrumentProperty(value: 1, minimum: -2, maximum: -2)
    var scaling     = AKInstrumentProperty(value: 1, minimum: 0.0, maximum: 3.0)
    var sampleMix   = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1)
    
    
    // INSTRUMENT DEFINITION ===============================================
    override init() {
        super.init()
        
        addProperty(speed)
        addProperty(scaling)
        addProperty(sampleMix)
        
        let file1 = String(NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")!)
        let file2 = String(NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")!)
        
        let fileIn1 = AKFileInput(filename: file1)
        fileIn1.speed = speed;
        connect(fileIn1)
        
        let fileIn2 = AKFileInput(filename: file2)
        fileIn2.speed = speed;
        connect(fileIn2)

        var fileInLeft  = AKMix(input1: fileIn1.leftOutput,  input2: fileIn2.leftOutput, balance: sampleMix)
        connect(fileInLeft)
        var fileInRight = AKMix(input1: fileIn1.rightOutput, input2: fileIn2.rightOutput, balance: sampleMix)
        connect(fileInRight)

        var leftF = AKFFT(
            input: fileInLeft.scaledBy(0.25.ak),
            fftSize: (1024.ak),
            overlap: (256.ak),
            windowType: AKFFTWindowType.Hamming,
            windowFilterSize: (1024.ak)
        )
        connect(leftF)
        
        var leftR = AKFFT(
            input: fileInRight.scaledBy(0.25.ak),
            fftSize: (1024.ak),
            overlap: (256.ak),
            windowType: AKFFTWindowType.Hamming,
            windowFilterSize: (1024.ak)
        )
        connect(leftR)

        
        var scaledLeftF = AKScaledFFT(
            signal: leftF,
            frequencyRatio: scaling
        )
        connect(scaledLeftF)
        
        var scaledLeftR = AKScaledFFT(
            signal: leftR,
            frequencyRatio: scaling
        )
        connect(scaledLeftR)

        var scaledLeft  = AKResynthesizedAudio(signal: scaledLeftF)
        var scaledRight = AKResynthesizedAudio(signal: scaledLeftR)
        
        var mono = AKMix(input1: scaledLeft, input2: scaledRight, balance: 0.5.ak)
        
        // Output to global effects processing
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: mono)
    }
}