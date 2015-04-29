//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = StruckMetalBarNote()
        let struckMetalBar = AKStruckMetalBar()
        struckMetalBar.strikePosition = note.strikePosition
        struckMetalBar.strikeWidth = note.strikeWidth
        setAudioOutput(struckMetalBar)

        enableParameterLog(
            "Strike Position = ",
            parameter: struckMetalBar.strikePosition,
            timeInterval:1
        )
        enableParameterLog(
            "Strike Width = ",
            parameter: struckMetalBar.strikeWidth,
            timeInterval:1
        )
    }
}

class StruckMetalBarNote: AKNote {
    var strikePosition = AKNoteProperty()
    var strikeWidth = AKNoteProperty()

    override init() {
        super.init()
        addProperty(strikePosition)
        addProperty(strikeWidth)
    }


    convenience init(strikePostion: Float, strikeWidth: Float) {
        self.init()
        self.strikePosition.floatValue = strikePostion
        self.strikeWidth.floatValue = strikeWidth
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = StruckMetalBarNote(strikePostion: Float(i)/20.0, strikeWidth: Float(i)/50)
    note.duration.floatValue = 1.0
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
