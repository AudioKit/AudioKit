//
//  Tambourine.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class Tambourine : AKInstrument {
    
    override init() {
        super.init()
        
        // Note Properties
        var note = TambourineNote()
        addNoteProperty(note.intensity)
        addNoteProperty(note.dampingFactor)
        
        let tambourine = AKTambourine()
        tambourine.intensity = note.intensity
        tambourine.dampingFactor = note.dampingFactor
        connect(tambourine)
        
        let out = AKAudioOutput(input: tambourine)
        connect(out)
    }
}



class TambourineNote: AKNote {
    
    // Note Properties
    var intensity = AKNoteProperty(value: 20, minimum: 0, maximum: 1000)
    var dampingFactor = AKNoteProperty(value: 0, minimum: 0, maximum: 1)
    
    override init() {
        super.init()
        addProperty(intensity)
        addProperty(dampingFactor)
        
        // Optionally set a default note duration
        duration.value = (1.0)
    }
    
    convenience init(intensity:Float, dampingFactor:Float) {
        self.init()
        
        self.intensity.value = intensity
        self.dampingFactor.value = dampingFactor
    }
}