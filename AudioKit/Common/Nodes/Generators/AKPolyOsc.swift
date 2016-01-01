//
//  AKPolyOsc.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPolyOsc: AKNode  {
    
    // MARK: - Properties
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    public var internalOscs:[AKOscillator] = []
    var notesPlayed:[Int] = []
    var voicePlaying = 0
    var numVoices = 1
    let subMixer = AKMixer()
    
    //init w/ polyphony
    public init(table: AKTable = AKTable(.Sine), numVoicesInit: Int = 1){
        
        print("creating an osc with \(numVoicesInit) voices")
        
        //set up the voices
        //internalOscs = [AKOscillator](count: numVoicesInit, repeatedValue: AKOscillator()) //doesn't work - creates just one osc
        notesPlayed = [Int](count: numVoicesInit, repeatedValue: 0)
        numVoices = numVoicesInit
        self.avAudioNode = subMixer.avAudioNode
        for (var i = 0 ; i < numVoices; ++i){
            internalOscs.append(AKOscillator(table: table))
            subMixer.connect(internalOscs[i])
        }
        
    }
    
    public func startNote(note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0
        
        internalOscs[voicePlaying].frequency = frequency
        internalOscs[voicePlaying].amplitude = amplitude
        notesPlayed[voicePlaying] = Int(note)
        print("Voice playing is \(voicePlaying) - note:\(note) - freq:\(internalOscs[voicePlaying].frequency)")
        
        voicePlaying = (voicePlaying + 1) % numVoices
                for (var i = 0; i < numVoices; ++i){
                    print("Voice \(i) freq is \(internalOscs[i].frequency)")
                }
    }
    
    public func stopNote(note: UInt8, onChannel channel: UInt8) {
        
        let voiceToStop = notesPlayed.indexOf(Int(note))
        print("voiceToStop: \(voiceToStop) - note:\(note)")
        internalOscs[voiceToStop!].amplitude = 0
    }
}
