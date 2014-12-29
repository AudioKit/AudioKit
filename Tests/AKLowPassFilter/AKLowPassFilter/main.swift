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

        let operation = AKLowPassFilter(audioSource: audioSource)
        operation.halfPowerPoint = halfPower.scaledBy(500.ak).plus(500.ak)
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
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
