//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let source = AKFMOscillator()
        connect(source)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let centerFrequency = AKLine(firstPoint: 220.ak, secondPoint: 3000.ak, durationBetweenPoints: testDuration.ak)
        connect(centerFrequency)

        let bandwidth = AKLine(firstPoint: 10.ak, secondPoint: 100.ak, durationBetweenPoints: testDuration.ak)
        connect(bandwidth)

        let resonantFilter = AKResonantFilter(audioSource: audioSource)
        resonantFilter.centerFrequency = centerFrequency
        resonantFilter.bandwidth = bandwidth
        connect(resonantFilter)

        let balance = AKBalance(input: resonantFilter, comparatorAudioSource: audioSource)
        connect(balance)

        enableParameterLog(
            "Center Frequency = ",
            parameter: resonantFilter.centerFrequency,
            timeInterval:0.2
        )

        enableParameterLog(
            "Bandwidth = ",
            parameter: resonantFilter.bandwidth,
            timeInterval:0.2
        )

        connect(AKAudioOutput(audioSource:balance))

        resetParameter(audioSource)
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
