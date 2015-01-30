//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()
        
        let note = VCONote()
        addNoteProperty(note.waveformType)

        let pulseWidthLine = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 10.ak)
        connect(pulseWidthLine)

        let frequencyLine = AKLine(firstPoint: 110.ak, secondPoint: 880.ak, durationBetweenPoints: 10.ak)
        connect(frequencyLine)


        let vcOscillator = AKVCOscillator()
        vcOscillator.waveformType = note.waveformType
        vcOscillator.pulseWidth = pulseWidthLine
        vcOscillator.frequency = frequencyLine
        connect(vcOscillator)

        connect(AKAudioOutput(audioSource:vcOscillator))
    }
}


class VCONote: AKNote {
    var waveformType = AKNoteProperty()
    
    override init() {
        super.init()
        addProperty(waveformType)
    }
    
    convenience init(waveformType: AKConstant) {
        self.init()
        self.waveformType.setValue(waveformType.value())
    }
}



let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)
let note1 = VCONote(waveformType: AKVCOscillator.waveformTypeForSquare())
let note2 = VCONote(waveformType: AKVCOscillator.waveformTypeForSawtooth())
let note3 = VCONote(waveformType: AKVCOscillator.waveformTypeForSquareWithPWM())
let note4 = VCONote(waveformType: AKVCOscillator.waveformTypeForTriangleWithRamp())

note1.duration.setValue(2.0)
note2.duration.setValue(2.0)
note3.duration.setValue(2.0)
note4.duration.setValue(2.0)

instrument.playNote(note1)
instrument.playNote(note2, afterDelay: 2.0)
instrument.playNote(note3, afterDelay: 4.0)
instrument.playNote(note4, afterDelay: 6.0)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
