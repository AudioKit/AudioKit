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
    var speed       = AKInstrumentProperty(value: 1, minimum: -2, maximum: 2)
    var scaling     = AKInstrumentProperty(value: 1, minimum: 0.0, maximum: 3.0)
    var sampleMix   = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1)
    
    
    // INSTRUMENT DEFINITION ===============================================
    override init() {
        super.init()
        
        addProperty(speed)
        addProperty(scaling)
        addProperty(sampleMix)
                
        let file1 = AKManager.pathToSoundFile("PianoBassDrumLoop", ofType: "wav")
        let file2 = AKManager.pathToSoundFile("808loop",           ofType: "wav")
        
        let fileIn1 = AKFileInput(filename: file1!)
        fileIn1.speed = speed
        fileIn1.loop = true
        
        let fileIn2 = AKFileInput(filename: file2!)
        fileIn2.speed = speed
        fileIn2.loop = true

        var fileInLeft  = AKMix(input1: fileIn1.leftOutput,  input2: fileIn2.leftOutput,  balance: sampleMix)
        var fileInRight = AKMix(input1: fileIn1.rightOutput, input2: fileIn2.rightOutput, balance: sampleMix)

        var leftF = AKFFT(
            input: fileInLeft.scaledBy(0.25.ak),
            fftSize: 1024.ak,
            overlap: 256.ak,
            windowType: AKFFT.hammingWindow(),
            windowFilterSize: 1024.ak
        )
        
        var leftR = AKFFT(
            input: fileInRight.scaledBy(0.25.ak),
            fftSize: 1024.ak,
            overlap: 256.ak,
            windowType: AKFFT.hammingWindow(),
            windowFilterSize: 1024.ak
        )
        
        var scaledLeftF = AKScaledFFT(
            signal: leftF,
            frequencyRatio: scaling
        )
        
        var scaledLeftR = AKScaledFFT(
            signal: leftR,
            frequencyRatio: scaling
        )

        var scaledLeft  = AKResynthesizedAudio(signal: scaledLeftF)
        var scaledRight = AKResynthesizedAudio(signal: scaledLeftR)
        
        var mono = AKMix(input1: scaledLeft, input2: scaledRight, balance: 0.5.ak)
        
        // Output to global effects processing
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: mono)
    }
}