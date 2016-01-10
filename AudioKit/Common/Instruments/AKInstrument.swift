//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Protocol for sounds that could be played on a traditional keyboard
public protocol AKKeyboardPlayable {
    func start(note: Int, velocity: Int)
    func stop(note: Int)
}

/// Protocol for all AudioKit Nodes
public protocol AKVoice: AKNode, AKCopyableVoice, AKToggleable {
    // Combines these protocols to allow for things like the midi instrument to work
}

//make sure these voices can be replicated by making them have a copy function
public protocol AKCopyableVoice {
    /// Function to duplicate this oscillator
    func copy() -> AKVoice
}

public class AKPolyphonicInstrument: AKNode {
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    public var voices: [AKVoice] = []
    var notesPlayed: [Int] = []
    
    var voicePlaying = 0
    var voiceCount = 1
    
    public let output = AKMixer()
    
    public init(voice: AKVoice, voiceCount: Int = 1) {
        
        //set up the voices
        notesPlayed = [Int](count: voiceCount, repeatedValue: 0)
        self.voiceCount = voiceCount
        
        self.avAudioNode = output.avAudioNode
        
        for (var i = 0 ; i < voiceCount; ++i) {
            voices.append(voice.copy())
            output.connect(voices[i])
            voices[i].stop()
        }
    }
    
    public func startNote(note: Int, velocity: Int) {
        notesPlayed[voicePlaying] = note
        startVoice(voicePlaying, note: note, velocity: velocity)
        voicePlaying = (voicePlaying + 1) % voiceCount
    }
    
    public func startVoice(voice: Int, note: Int, velocity: Int) {
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity)")
    }
    
    public func stopNote(note: Int) {
        var voiceToStop = notesPlayed.indexOf(note)
        while(voiceToStop != nil) {
            stopVoice(voiceToStop!, note: note)
            notesPlayed[voiceToStop!] = 0
            voiceToStop = notesPlayed.indexOf(note)
        }
    }
    
    public func stopVoice(voice: Int, note: Int) {
        print("Stopping voice\(voice) - note:\(note)")
    }
    
    public func panic() {
        for(var i = 0; i < voiceCount; i++) {
            voices[i].stop()
        }
    }    
}