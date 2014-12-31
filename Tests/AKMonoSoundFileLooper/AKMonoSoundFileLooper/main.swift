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

        let filename = "CsoundLib64.framework/Sounds/mandpluk.aif"

        let soundFile = AKSoundFile(filename: filename)
        connect(soundFile)

        let speed = AKLine(firstPoint: 10.ak, secondPoint: 0.2.ak, durationBetweenPoints: testDuration.ak)
        connect(speed)

        let monoSoundFileLooper = AKMonoSoundFileLooper(soundFile: soundFile)
        monoSoundFileLooper.frequencyRatio = speed
        monoSoundFileLooper.loopMode = AKSoundFileLooperMode.Normal
        connect(monoSoundFileLooper)
        
        enableParameterLog(
            "Speed = ",
            parameter: monoSoundFileLooper.frequencyRatio,
            frequency:0.1
        )

        connect(AKAudioOutput(audioSource:monoSoundFileLooper))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
