//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()
        setAudioOutput(AKDroplet())
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()
for index in 1...100 {
    let note = AKNote()
    let time = Float(index) / 10.0
    phrase.addNote(note, atTime:time)
}
instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
