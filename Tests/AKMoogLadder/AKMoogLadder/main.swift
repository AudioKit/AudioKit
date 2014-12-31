//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

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

        let resonance = AKLine(firstPoint: 0.1.ak, secondPoint: 1.0.ak, durationBetweenPoints: testDuration.ak)
        connect(resonance)

        let cutoffFrequency = AKLine(firstPoint: 100.ak, secondPoint: 10000.ak, durationBetweenPoints: testDuration.ak)
        connect(cutoffFrequency)

        let moogLadder = AKMoogLadder(input: audioSource)
        moogLadder.resonance = resonance
        moogLadder.cutoffFrequency = cutoffFrequency
        connect(moogLadder)

        enableParameterLog(
            "Resonance = ",
            parameter: moogLadder.resonance,
            frequency:0.1
        )
        
        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: moogLadder.cutoffFrequency,
            frequency:0.1
        )
        
        connect(AKAudioOutput(audioSource:moogLadder))
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
