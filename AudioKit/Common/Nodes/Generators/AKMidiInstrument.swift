//
//  AKMidiInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

public class AKMidiInstrument: AVAudioUnitMIDIInstrument {
    
    public override init() {
        
        print("creating akmidiinstrument")
        
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_MusicDevice
        description.componentSubType      = kAudioUnitSubType_MIDISynth
        description.componentManufacturer = kAudioUnitManufacturer_Apple//0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        
        super.init(audioComponentDescription: description)
        AKManager.sharedInstance.engine.attachNode(self)
        
    }
    
    public override func sendMIDIEvent(midiStatus: UInt8,
        data1: UInt8,
        data2: UInt8){
            print("midi")
    }
    
    public override func startNote(note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        super.startNote(note, withVelocity: velocity, onChannel: channel)
        
        print("I'm being asked to play \(note) with velocity \(velocity)")
        
    }
    
    public override func stopNote(note: UInt8, onChannel channel: UInt8) {
        super.stopNote(note, onChannel: channel)
        
        print("I'm being asked to stop note \(note)")
    }
}