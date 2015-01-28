//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let soundfile = AKSoundFile (filename: filename)
        soundfile.size = 16384
        connect(soundfile)

        let hamming = AKWindow(type: AKWindowTableType.Hamming)
        hamming.size = 512;
        connect(hamming)

        let baseFrequency = AKConstant(expression: String(format: "44100 / %@", soundfile.length()))

        let grainDensityLine = AKLine(firstPoint: 600.ak, secondPoint: 10.ak, durationBetweenPoints: 10.ak)
        connect(grainDensityLine)

        let grainDurationLine = AKLine(firstPoint: 0.4.ak, secondPoint: 0.1.ak, durationBetweenPoints: 10.ak)
        connect(grainDurationLine)

        let grainAmplitudeLine = AKLine(firstPoint: 0.2.ak, secondPoint: 0.5.ak, durationBetweenPoints: 10.ak)
        connect(grainAmplitudeLine)

        let maximumFrequencyDeviationLine = AKLine(firstPoint: 0.ak, secondPoint: 0.1.ak, durationBetweenPoints: 10.ak)
        connect(maximumFrequencyDeviationLine)

        let granularSynthesisTexture = AKGranularSynthesisTexture(
            grainFunctionTable: soundfile,
            windowFunctionTable: hamming
        )
        granularSynthesisTexture.grainFrequency = baseFrequency
        granularSynthesisTexture.grainDensity = grainDensityLine
        granularSynthesisTexture.averageGrainDuration = grainDurationLine
        granularSynthesisTexture.maximumFrequencyDeviation = maximumFrequencyDeviationLine
        granularSynthesisTexture.grainAmplitude = grainAmplitudeLine
        connect(granularSynthesisTexture)

        enableParameterLog(
            "Grain Frequency = ",
            parameter: granularSynthesisTexture.grainFrequency,
            timeInterval:0.2
        )

        enableParameterLog(
            "Grain Density = ",
            parameter: granularSynthesisTexture.grainDensity,
            timeInterval:0.2
        )

        enableParameterLog(
            "Average Grain Duration = ",
            parameter: granularSynthesisTexture.averageGrainDuration,
            timeInterval:0.2
        )

        enableParameterLog(
            "Maximum Frequency Deviation = ",
            parameter: granularSynthesisTexture.maximumFrequencyDeviation,
            timeInterval:0.2
        )

        enableParameterLog(
            "Grain Amplitude  = ",
            parameter: granularSynthesisTexture.grainAmplitude,
            timeInterval:0.2
        )


        connect(AKAudioOutput(audioSource:granularSynthesisTexture))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
