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

    override init() {
        super.init()

        let filename = "CsoundLib64.framework/Sounds/808loop.wav"

        let soundFile = AKSoundFile(filename: filename)
        connect(soundFile)

        let speed = AKLine(firstPoint: 4.ak, secondPoint: 0.2.ak, durationBetweenPoints: testDuration.ak)
        connect(speed)

        let stereoSoundFileLooper = AKStereoSoundFileLooper(soundFile: soundFile)
        stereoSoundFileLooper.frequencyRatio = speed
        stereoSoundFileLooper.loopMode = AKStereoSoundFileLooper.loopPlaysForwardAndThenBackwards()
        connect(stereoSoundFileLooper)

        enableParameterLog(
            "Speed = ",
            parameter: stereoSoundFileLooper.frequencyRatio,
            timeInterval:0.1
        )

        connect(AKAudioOutput(stereoAudioSource:stereoSoundFileLooper))
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
