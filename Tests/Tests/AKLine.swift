//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()
        
        let line = AKLine()
        line.secondPoint = 100.ak
        enableParameterLog("line value = ", parameter: line, timeInterval:0.5)

        let oscillator = AKOscillator()
        oscillator.frequency = line
        setAudioOutput(oscillator)
    }
}

AKOrchestra.testForDuration(10)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
