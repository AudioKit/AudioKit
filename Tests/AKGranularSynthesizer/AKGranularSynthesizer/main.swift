//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let filename = "CsoundLib64.framework/Sounds/808loop.wav"
        
        let soundFile = AKSoundFile(filename: filename)
        soundFile.size = 16384
        AKManager.sharedManager().orchestra.functionTables.addObject(soundFile)
        
        let synth = AKGranularSynthesizer(
            grainWaveform: soundFile,
            frequency: 220.ak
        )
        synth.duration = 1.0.ak
        connect(synth)
        
        connect(AKAudioOutput(audioSource:synth))
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
