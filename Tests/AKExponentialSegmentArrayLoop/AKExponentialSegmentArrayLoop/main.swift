//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10;

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let segmentLoop = AKLinearSegmentArrayLoop(
            frequency: 1.ak,
            initialValue: 440.ak
        )
        segmentLoop.addValue(550.ak, afterDuration: 1.ak)
        segmentLoop.addValue(330.ak, afterDuration: 2.ak)
        segmentLoop.addValue(440.ak, afterDuration: 1.ak)
        connect(segmentLoop)
        
        enableParameterLog("segment value = ", parameter: segmentLoop, timeInterval: 0.1)
        
        let oscillator = AKOscillator()
        oscillator.frequency = segmentLoop
        connect(oscillator)
        
        let output = AKAudioOutput(audioSource: oscillator)
        connect(output)
    }
}


// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")