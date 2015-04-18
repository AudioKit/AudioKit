//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/mandpluk.aif"
        let soundFile = AKSoundFileTable(filename: filename)
        let speed = AKLine(
            firstPoint:  3.ak,
            secondPoint: 0.5.ak,
            durationBetweenPoints: testDuration.ak
        )

        let tableLooper = AKTableLooper(table: soundFile)
        tableLooper.endTime = 9.6.ak
        tableLooper.transpositionRatio = speed
        tableLooper.loopMode = AKTableLooper.loopPlaysForwardAndThenBackwards()

        enableParameterLog(
            "Transposition Ratio = ",
            parameter: tableLooper.transpositionRatio,
            timeInterval:0.1
        )
        setAudioOutput(tableLooper)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
