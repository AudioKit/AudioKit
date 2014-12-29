//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let operation = AKFMOscillator()
        connect(operation)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:operation)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let cutoffFrequency = AKLinearControl(firstPoint: 220.ak, secondPoint: 3000.ak, durationBetweenPoints: 11.ak)
        connect(cutoffFrequency)

        let bandwidth = AKLinearControl(firstPoint: 10.ak, secondPoint: 100.ak, durationBetweenPoints: 11.ak)
        connect(bandwidth)

        let operation = AKVariableFrequencyResponseBandPassFilter(audioSource: audioSource)
        operation.cutoffFrequency = cutoffFrequency
        operation.bandwidth = bandwidth
        connect(operation)

        let balance = AKBalance(input: operation, comparatorAudioSource: audioSource)
        connect(balance)

        connect(AKAudioOutput(audioSource:balance))
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(10)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
