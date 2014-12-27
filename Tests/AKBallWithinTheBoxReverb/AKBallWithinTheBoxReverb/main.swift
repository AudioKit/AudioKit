//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Customized by Nick Arner on 12/26/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/808Loop.wav"
        
        let audio = AKFileInput(filename: filename)
        connect(audio)
        
        let mono = AKMixedAudio(signal1: audio.leftOutput, signal2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let xLocation = AKLinearControl(firstPoint: 1.ak, secondPoint: 6.ak, durationBetweenPoints: 11.ak)
        connect(xLocation)
        
        let yLocation = AKLinearControl(firstPoint: 1.ak, secondPoint: 4.ak, durationBetweenPoints: 11.ak)
        connect(yLocation)

        let zLocation = AKLinearControl(firstPoint: 1.ak, secondPoint: 3.ak, durationBetweenPoints: 11.ak)
        connect(zLocation)

        let operation = AKBallWithinTheBoxReverb(input: audioSource)
        operation.xLocation = xLocation
        operation.yLocation = yLocation
        operation.zLocation = zLocation
        operation.diffusion = 0.0.ak
        connect(operation)
        
        let mix = AKMixedAudio(signal1: audioSource, signal2: operation.leftOutput, balance: 0.1.ak)
        connect(mix)
        
        connect(AKAudioOutput(audioSource:mix))
    }
}

// Set Up
let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

processor.play()
instrument.playNote(AKNote(), afterDelay: 0.5)


while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")