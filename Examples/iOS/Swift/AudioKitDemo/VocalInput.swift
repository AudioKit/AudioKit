//
//  VocalInput.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class VocalInput: AKInstrument{
    
    override init() {
        super.init()
        
        let microphone = AKAudioInput()
        connect(microphone)
        let auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to: microphone)
    }
}

