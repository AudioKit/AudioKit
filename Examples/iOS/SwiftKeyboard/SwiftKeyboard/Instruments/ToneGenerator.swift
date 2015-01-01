//
//  ToneGenerator.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

class ToneGenerator: AKInstrument {

    // Instrument Properties
    var toneColor  = AKInstrumentProperty(value: 0.5, minimum: 0.1, maximum: 1.0)
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()

        // Instrument Properties
        addProperty(toneColor)

        // Note Properties
        let note = ToneGeneratorNote()
        addNoteProperty(note.frequency)
        addNoteProperty(note.releasing)
    
        let fmOscillator = AKFMOscillator(
            functionTable: AKManager.standardSineWave(),
            baseFrequency: note.frequency,
            carrierMultiplier: toneColor.scaledBy(20.ak),
            modulatingMultiplier: toneColor.scaledBy(12.ak),
            modulationIndex: toneColor.scaledBy(15.ak),
            amplitude: 0.15.ak,
            phase: 0.ak)
        connect(fmOscillator)
        
        let portamento = AKPortamento(input: note.releasing)
        portamento.halfTime = 0.25.ak
        connect(portamento)
        
        let gain = AKAssignment(input: fmOscillator.scaledBy(1.0.ak.minus(portamento)))
        connect(gain)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: gain)
    }
}

class ToneGeneratorNote: AKNote {
    
    // Note Properties
    var frequency = AKNoteProperty(minimum: 440, maximum: 880)
    var releasing = AKNoteProperty(minimum: 0, maximum: 1)
    override init() {
        super.init()
        addProperty(frequency)
        addProperty(releasing)
        releasing.value = 0.0
    }
}