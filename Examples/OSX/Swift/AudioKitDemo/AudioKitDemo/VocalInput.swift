//
//  VocalInput.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class VocalInput: AKInstrument{
    
    let auxilliaryOutput = AKAudio.globalParameter()
    
    override init() {
        super.init()
        
        let microphone = AKAudioInput()
        connect(microphone)
        assignOutput(auxilliaryOutput, to: microphone)
    }
}
