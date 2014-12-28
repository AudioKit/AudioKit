//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Customized by Nick Arner and Aurelius Prochazka on 12/27/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()

        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let soundfile = AKSoundFile (filename: filename)
        soundfile.size = 16384
        connect(soundfile)
        
        let hamming = AKWindowsTable (type: AKWindowTableType.Hamming, size: 512)
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
        
        let operation = AKGranularSynthesisTexture(
            grainFunctionTable: soundfile,
            windowFunctionTable: hamming
        )
        operation.grainFrequency = baseFrequency
        operation.grainDensity = grainDensityLine
        operation.averageGrainDuration = grainDurationLine
        operation.maximumFrequencyDeviation = maximumFrequencyDeviationLine
        operation.grainAmplitude = grainAmplitudeLine
        connect(operation)
        
        connect(AKAudioOutput(audioSource:operation))
    }
}


// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
