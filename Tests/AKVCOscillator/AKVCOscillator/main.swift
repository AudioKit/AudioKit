//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let pulseWidthLine = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 10.ak)
        connect(pulseWidthLine)

        let frequencyLine = AKLine(firstPoint: 110.ak, secondPoint: 880.ak, durationBetweenPoints: 10.ak)
        connect(frequencyLine)


        let vcOscillator = AKVCOscillator()
        vcOscillator.waveformType = AKVCOscillatorWaveformType.SquarePWM
        vcOscillator.pulseWidth = pulseWidthLine
        vcOscillator.frequency = frequencyLine
        connect(vcOscillator)

        enableParameterLog(
            "Pulse Width = ",
            parameter: vcOscillator.pulseWidth,
            timeInterval:0.1
        )

        enableParameterLog(
            "Frequency = ",
            parameter: vcOscillator.frequency,
            timeInterval:0.1
        )


        connect(AKAudioOutput(audioSource:vcOscillator))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
