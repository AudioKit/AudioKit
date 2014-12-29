//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "CsoundLib64.framework/Sounds/mandpluk.aif"

        let soundFile = AKSoundFile(filename: filename)
        connect(soundFile)

        let speed = AKLine(firstPoint: 3.ak, secondPoint: 0.5.ak, durationBetweenPoints: 10.ak)
        connect(speed)

        let operation = AKFunctionTableLooper(functionTable: soundFile)
        operation.endTime = 9.6.ak
        operation.transpositionRatio = speed
        operation.loopMode = AKFunctionTableLooperMode.ForwardAndBack
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
