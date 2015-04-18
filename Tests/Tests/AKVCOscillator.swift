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

        let pulseWidthLine = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 10.ak)
        let frequencyLine = AKLine(firstPoint: 110.ak, secondPoint: 880.ak, durationBetweenPoints: 10.ak)

        let note = VCONote()
        let vcOscillator = AKVCOscillator()
        vcOscillator.waveformType = note.waveformType
        vcOscillator.pulseWidth = pulseWidthLine
        vcOscillator.frequency = frequencyLine
        setAudioOutput(vcOscillator)

        enableParameterLog(
            "\n\n\nWaveform Type = ",
            parameter: note.waveformType,
            timeInterval:10
        )

        enableParameterLog(
            "Frequency = ",
            parameter: frequencyLine,
            timeInterval:0.2
        )

        enableParameterLog(
            "Pulse Width = ",
            parameter: pulseWidthLine,
            timeInterval:0.2
        )
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
        self.waveformType.floatValue = waveformType.floatValue
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note1 = VCONote(waveformType: AKVCOscillator.waveformTypeForSquare())
let note2 = VCONote(waveformType: AKVCOscillator.waveformTypeForSawtooth())
let note3 = VCONote(waveformType: AKVCOscillator.waveformTypeForSquareWithPWM())
let note4 = VCONote(waveformType: AKVCOscillator.waveformTypeForTriangleWithRamp())

note1.duration.floatValue = 2.0
note2.duration.floatValue = 2.0
note3.duration.floatValue = 2.0
note4.duration.floatValue = 2.0

instrument.playNote(note1)
instrument.playNote(note2, afterDelay: 2.0)
instrument.playNote(note3, afterDelay: 4.0)
instrument.playNote(note4, afterDelay: 6.0)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
