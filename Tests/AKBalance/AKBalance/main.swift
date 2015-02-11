//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 4.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let amplitude = AKOscillator()
        amplitude.frequency = 1.ak
        connect(amplitude)

        let oscillator = AKOscillator()
        oscillator.amplitude = amplitude
        connect(oscillator)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:oscillator)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let synth = AKFMOscillator()
        connect(synth)

        let balanced = AKBalance(input: synth, comparatorAudioSource: audioSource)
        connect(balanced)

        connect(AKAudioOutput(audioSource:balanced))

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
