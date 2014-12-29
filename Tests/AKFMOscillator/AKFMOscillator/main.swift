//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/1/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let frequencyLine = AKLine(firstPoint: 10.ak, secondPoint: 880.ak, durationBetweenPoints: 11.ak)
        connect(frequencyLine)

        let carrierMultiplierLine = AKLine(firstPoint: 2.ak, secondPoint: 0.ak, durationBetweenPoints: 11.ak)
        connect(carrierMultiplierLine)

        let modulatingMultiplierLine = AKLine(firstPoint: 0.ak, secondPoint: 2.ak, durationBetweenPoints: 11.ak)
        connect(modulatingMultiplierLine)

        let indexLine = AKLine(firstPoint: 0.ak, secondPoint: 30.ak, durationBetweenPoints: 11.ak)
        connect(indexLine)

        let operation = AKFMOscillator()
        operation.baseFrequency = frequencyLine
        operation.carrierMultiplier = carrierMultiplierLine
        operation.modulatingMultiplier = modulatingMultiplierLine
        operation.modulationIndex = indexLine
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(10)
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
