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
        
        let sine = AKSineTable()
        addFTable(sine)
        
        let fmOscillator = AKFMOscillator(
            FTable: sine,
            baseFrequency: note.frequency,
            carrierMultiplier: toneColor.scaledBy(2.ak),
            modulatingMultiplier: toneColor.scaledBy(1.2.ak),
            modulationIndex: toneColor.scaledBy(1.5.ak),
            amplitude: 0.15.ak,
            phase: 0.ak)
        connect(fmOscillator)
        
        let output = AKAudioOutput(audioSource: fmOscillator)
        connect(output)
    }
}


class ToneGeneratorNote: AKNote {
    
    // Note Properties
    var frequency = AKNoteProperty(minimum: 440, maximum: 880)
    
    override init() {
        super.init()
        addProperty(frequency)
    }
}