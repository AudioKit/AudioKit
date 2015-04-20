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

        let filename = "AKSoundFiles.bundle/Sounds/808loop.wav"
        let soundFile = AKSoundFileTable(filename: filename)
        let stereoSoundFileLooper = AKStereoSoundFileLooper(soundFile: soundFile)

        let speed = AKLine(firstPoint: 4.ak, secondPoint: 0.2.ak, durationBetweenPoints: testDuration.ak)
        stereoSoundFileLooper.frequencyRatio = speed

        stereoSoundFileLooper.loopMode = AKStereoSoundFileLooper.loopPlaysForwardAndThenBackwards()

        setAudioOutput(stereoSoundFileLooper)

        enableParameterLog(
            "Speed = ",
            parameter: stereoSoundFileLooper.frequencyRatio,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
