//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let note = StruckMetalBarNote()
        addNoteProperty(note.strikePosition)
        addNoteProperty(note.strikeWidth)
        
        let struckMetalBar = AKStruckMetalBar()
        struckMetalBar.strikePosition = note.strikePosition
        struckMetalBar.strikeWidth = note.strikeWidth
        connect(struckMetalBar)
        
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
        connect(AKAudioOutput(audioSource:struckMetalBar))
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
        self.strikePosition.setValue(strikePostion)
        self.strikeWidth.setValue(strikeWidth)
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)
let phrase = AKPhrase()

for i in 1...10 {
    let note = StruckMetalBarNote(strikePostion: Float(i)/20.0, strikeWidth: Float(i)/50)
    note.duration.setValue(1.0)
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
