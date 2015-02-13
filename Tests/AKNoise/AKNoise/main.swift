//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10

class Instrument : AKInstrument {

    override init() {
        super.init()
        
        let pinkBalanceLine = AKLine(firstPoint:0.ak, secondPoint: 1.ak, durationBetweenPoints: testDuration.ak)
        connect(pinkBalanceLine)
        let betaLine = AKLine(firstPoint:(-0.99).ak, secondPoint: 0.99.ak, durationBetweenPoints: testDuration.ak)
        connect(betaLine)
        
        
        let noise = AKNoise()
        noise.pinkBalance = pinkBalanceLine
        noise.beta = betaLine
        connect(noise)

        connect(AKAudioOutput(audioSource:noise))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")