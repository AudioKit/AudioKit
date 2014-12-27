//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Customized by Nick Arner on 12/21/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let operation = AKPhasor()
        connect(operation)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:operation)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let line1 = AKLinearControl(firstPoint: 0.1.ak, secondPoint: 1.0.ak, durationBetweenPoints: 11.ak)
        connect(line1)

        let line2 = AKLinearControl(firstPoint: 100.ak, secondPoint: 10000.ak, durationBetweenPoints: 11.ak)
        connect(line2)

        let operation = AKMoogLadder(input: audioSource)
        operation.resonance = line1
        operation.cutoffFrequency = line2
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)
processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
