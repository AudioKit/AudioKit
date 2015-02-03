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
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMix(
            input1: audio.leftOutput,
            input2: audio.rightOutput,
            balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let centerFrequency = AKLine(firstPoint: 10000.ak, secondPoint: 0.ak, durationBetweenPoints: testDuration.ak)
        connect(centerFrequency)

        let bandwidth = AKLine(firstPoint: 100.ak, secondPoint: 2000.ak, durationBetweenPoints: testDuration.ak)
        connect(bandwidth)

        let bandRejectFilter = AKBandRejectButterworthFilter(input: audioSource)
        bandRejectFilter.centerFrequency = centerFrequency
        bandRejectFilter.bandwidth = bandwidth
        connect(bandRejectFilter)

        enableParameterLog(
            "Center Frequency = ",
            parameter: bandRejectFilter.centerFrequency,
            timeInterval:0.1
        )
        enableParameterLog(
            "Bandwidth = ",
            parameter: bandRejectFilter.bandwidth,
            timeInterval:1
        )

        connect(AKAudioOutput(audioSource:bandRejectFilter))

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

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
