//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Nick Arner on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let frequency = AKLine(
            firstPoint:  0.ak,
            secondPoint: 1000.0.ak,
            durationBetweenPoints: testDuration.ak
        )

        let oscillator = AKOscillator()
        oscillator.frequency = frequency

        enableParameterLog(
            "Carrier Frequency = ",
            parameter: frequency,
            timeInterval:0.1
        )

        let ringModulator = AKRingModulator(input: audioSource, carrier: oscillator)

        setAudioOutput(ringModulator)

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
