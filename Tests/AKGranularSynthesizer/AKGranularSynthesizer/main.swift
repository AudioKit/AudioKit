//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 20.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "CsoundLib64.framework/Sounds/808loop.wav"

        let soundFile = AKSoundFile(filename: filename)
        soundFile.size = 16384
        AKManager.sharedManager().orchestra.functionTables.addObject(soundFile)

        let frequencyLine = AKLine(firstPoint: 0.1.ak, secondPoint: 0.2.ak, durationBetweenPoints: testDuration.ak)
        connect(frequencyLine)

        let synth = AKGranularSynthesizer(
            grainWaveform: soundFile,
            frequency: frequencyLine
        )
        synth.duration = 10.ak
        synth.frequencyVariation = 10.ak
        synth.frequencyVariationDistribution = 10.ak
        synth.density = 1.ak
        connect(synth)

        connect(AKAudioOutput(audioSource:synth.scaledBy(0.6.ak)))
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
