//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/mandpluk.aif"
        let soundFile = AKSoundFileTable(filename: filename)

        let speed = AKLine(
            firstPoint: 10.ak,
            secondPoint: 0.2.ak,
            durationBetweenPoints: testDuration.ak
        )

        let monoSoundFileLooper = AKMonoSoundFileLooper(soundFile: soundFile)
        monoSoundFileLooper.frequencyRatio = speed
        setAudioOutput(monoSoundFileLooper)

        enableParameterLog(
            "Speed = ",
            parameter: monoSoundFileLooper.frequencyRatio,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
