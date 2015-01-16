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
        addNoteProperty(note.amplitude)
        
        let adsr = AKLinearADSREnvelope()
        connect(adsr)
    
        let fmOscillator = AKFMOscillator()
        fmOscillator.baseFrequency = note.frequency
        fmOscillator.carrierMultiplier = toneColor.scaledBy(20.ak)
        fmOscillator.modulatingMultiplier = toneColor.scaledBy(12.ak)
        fmOscillator.modulationIndex = toneColor.scaledBy(15.ak)
        fmOscillator.amplitude = adsr.scaledBy(0.15.ak)
        connect(fmOscillator)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: fmOscillator)
    }
}

class ToneGeneratorNote: AKNote {
    
    // Note Properties
    var frequency = AKNoteProperty(minimum: 440, maximum: 880)
    var amplitude = AKNoteProperty(minimum: 0, maximum: 1)
    override init() {
        super.init()
        addProperty(frequency)
        addProperty(amplitude)
        amplitude.value = 1.0
    }
}