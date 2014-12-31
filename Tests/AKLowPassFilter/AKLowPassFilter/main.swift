//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let source = AKOscillator()
        connect(source)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let halfPower = AKLowFrequencyOscillator()
        halfPower.frequency = 0.5.ak
        connect(halfPower)

        let lowPassFilter = AKLowPassFilter(audioSource: audioSource)
        lowPassFilter.halfPowerPoint = halfPower.scaledBy(500.ak).plus(500.ak)
        connect(lowPassFilter)

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: lowPassFilter.halfPowerPoint,
            frequency:0.1
        )
        
        connect(AKAudioOutput(audioSource:lowPassFilter))
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
