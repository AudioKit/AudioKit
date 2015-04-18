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

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"

        let soundfile = AKSoundFileTable(filename: filename, size:16384)

        let hamming = AKTable(size: 512)
        hamming.populateTableWithGenerator(AKWindowTableGenerator.hammingWindow())

        let baseFrequency = AKConstant(expression: String(format: "44100 / %@", soundfile.length()))

        let grainDensityLine  =  AKLine(firstPoint: 600.ak, secondPoint: 10.ak,  durationBetweenPoints: 10.ak)
        let grainDurationLine =  AKLine(firstPoint: 0.4.ak, secondPoint: 0.1.ak, durationBetweenPoints: 10.ak)
        let grainAmplitudeLine = AKLine(firstPoint: 0.2.ak, secondPoint: 0.5.ak, durationBetweenPoints: 10.ak)
        let maximumFrequencyDeviationLine = AKLine(firstPoint: 0.ak, secondPoint: 0.1.ak, durationBetweenPoints: 10.ak)

        let granularSynthesisTexture = AKGranularSynthesisTexture(
            grainTable: soundfile,
            windowTable: hamming
        )
        granularSynthesisTexture.grainFrequency = baseFrequency
        granularSynthesisTexture.grainDensity = grainDensityLine
        granularSynthesisTexture.averageGrainDuration = grainDurationLine
        granularSynthesisTexture.maximumFrequencyDeviation = maximumFrequencyDeviationLine
        granularSynthesisTexture.grainAmplitude = grainAmplitudeLine

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

        setAudioOutput(granularSynthesisTexture)
    }
}

AKOrchestra.testForDuration(10)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
