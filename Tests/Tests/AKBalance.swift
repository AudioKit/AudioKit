//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 4.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let amplitude = AKOscillator()
        amplitude.frequency = 1.ak

        let oscillator = AKOscillator()
        oscillator.amplitude = amplitude

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:oscillator)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let synth = AKFMOscillator()
        let balanced = AKBalance(input: synth, comparatorAudioSource: audioSource)
        setAudioOutput(balanced)

        resetParameter(audioSource)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)

AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

processor.play()
instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
