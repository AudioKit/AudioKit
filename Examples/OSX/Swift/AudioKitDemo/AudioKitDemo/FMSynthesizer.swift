//
//  FMSynthesizer.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class FMSynthesizer: AKInstrument{
    
    override init() {
        super.init()
        
        // Note Properties
        let note = FMSynthesizerNote()
        
        let envelope = AKADSREnvelope(
            attackDuration:  0.1.ak,
            decayDuration:   0.1.ak,
            sustainLevel:    0.5.ak,
            releaseDuration: 0.3.ak,
            delay: 0.ak
        )
        
        let oscillator = AKFMOscillator()
        oscillator.baseFrequency        = note.frequency
        oscillator.carrierMultiplier    = note.color.scaledBy(2.ak)
        oscillator.modulatingMultiplier = note.color.scaledBy(3.ak)
        oscillator.modulationIndex      = note.color.scaledBy(10.ak)
        oscillator.amplitude            = envelope.scaledBy(0.25.ak)

        setAudioOutput(oscillator)
        
    }
}



class FMSynthesizerNote: AKNote {
    
    // Note Properties
    var frequency = AKNoteProperty(value: 440, minimum: 100, maximum: 20000)
    var color = AKNoteProperty(value: 0, minimum: 0, maximum: 1)
    
    override init() {
        super.init()
        addProperty(frequency)
        addProperty(color)
        
        // Optionally set a default note duration
        self.duration.setValue(1.0)
    }
    
    convenience init(frequency:Float, color:Float){
        self.init()
        
        self.frequency.setValue(frequency)
        self.color.setValue(color)
    }
}