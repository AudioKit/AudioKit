//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio);
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let centerFrequency = AKLine(
            firstPoint: 0.ak,
            secondPoint: 10000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let bandwidth = AKLine(
            firstPoint: 2000.ak,
            secondPoint: 20.ak,
            durationBetweenPoints: testDuration.ak
        )

        enableParameterLog(
            "Center Frequency = ",
            parameter: centerFrequency,
            timeInterval:0.1
        )
        enableParameterLog(
            "Bandwidth = ",
            parameter: bandwidth,
            timeInterval:1
        )

        let bandPassFilter = AKBandPassButterworthFilter(input: audioSource)
        bandPassFilter.centerFrequency = centerFrequency
        bandPassFilter.bandwidth = bandwidth

        setAudioOutput(bandPassFilter)

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
