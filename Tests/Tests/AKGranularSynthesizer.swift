//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/808loop.wav"

        let soundFile = AKSoundFileTable(filename: filename, size: 16384)

        let frequencyLine = AKLine(
            firstPoint:  0.1.ak,
            secondPoint: 0.2.ak,
            durationBetweenPoints: testDuration.ak
        )
        let synth = AKGranularSynthesizer(
            grainWaveform: soundFile,
            frequency: frequencyLine
        )
        synth.duration = 10.ak
        synth.frequencyVariation = 10.ak
        synth.frequencyVariationDistribution = 10.ak
        synth.density = 1.ak

        setAudioOutput(synth)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
