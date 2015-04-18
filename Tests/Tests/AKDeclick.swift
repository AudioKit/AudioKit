//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument1 : AKInstrument {

    override init() {
        super.init()
        let oscillator = AKOscillator()
        setAudioOutput(oscillator)
    }
}

class Instrument2 : AKInstrument {

    override init() {
        super.init()

        let oscillator = AKOscillator()
        let declick = AKDeclick(input: oscillator)
        setAudioOutput(declick)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument1 = Instrument1()
let instrument2 = Instrument2()
AKOrchestra.addInstrument(instrument1)
AKOrchestra.addInstrument(instrument2)

let note = AKNote()
note.duration.floatValue = 0.4

NSLog("Play 10 notes first without declicking")

let phrase1 = AKPhrase()
for index in 1...10 {
    let time = 0.5 * Float(index)
    phrase1.addNote(note,  atTime: time)
}
instrument1.playPhrase(phrase1)

NSLog("And then 10 notes with declicking")

let phrase2 = AKPhrase()
for index in 11...20 {
    let time = 0.5 * Float(index)
    phrase2.addNote(note,  atTime: time)
}
instrument2.playPhrase(phrase2)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
