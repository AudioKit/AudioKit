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
public class AKVoice: AKNode, AKToggleable {
    // Combines these protocols to allow for things like the midi instrument to work
    
    public var isStarted: Bool {
        return false
        // override in subclass
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        // override in subclass
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        // override in subclass
    }
    
    public func copy() -> AKVoice {
        return AKVoice()
        // override in subclass
    }
}

public class AKPolyphonicInstrument: AKNode {

    public var voices: [AKVoice] = []
    var notesPlayed: [Int] = []
    
    var voicePlaying = 0
    var voiceCount = 1
    
    public let output = AKMixer()
    
    public init(voice: AKVoice, voiceCount: Int = 1) {
        
        //set up the voices
        notesPlayed = [Int](count: voiceCount, repeatedValue: 0)
        self.voiceCount = voiceCount
        
        super.init()
        avAudioNode = output.avAudioNode
        
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