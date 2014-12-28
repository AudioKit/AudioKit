//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/28/14.
//  Customized by Aurelius Prochazka on 12/28/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let filename = "CsoundLib64.framework/Sounds/808loop.wav"
        
        let soundFile = AKSoundFile(filename: filename)
        connect(soundFile)
        
        let speed = AKLine(firstPoint: 4.ak, secondPoint: 0.2.ak, durationBetweenPoints: 10.ak)
        connect(speed)
        
        let operation = AKStereoSoundFileLooper(soundFile: soundFile)
        operation.frequencyRatio = speed
        operation.loopMode = AKSoundFileLooperMode.ForwardAndBack
        connect(operation)
        
        connect(AKAudioOutput(stereoAudioSource:operation))
    }
}


// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
