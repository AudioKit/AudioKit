//
//  AKInstrument.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Protocol for sounds that could be played on a traditional keyboard
protocol AKKeyboardPlayable {
    func start(note: Int, velocity: Int)
    func stop(note: Int)
}

/// Protocol for all AudioKit Nodes
public protocol AKVoice: AKNode, AKCopyableVoice, AKToggleable {
    // Combines these two protocols to allow for things like the midi instrument to work
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
    
    public func handleMidiNotification(notif: NSNotification) {
        let note = Int((notif.userInfo?["note"])! as! NSNumber)
        let vel = Int((notif.userInfo?["velocity"])! as! NSNumber)
        if notif.name == AKMidiStatus.NoteOn.name() && vel > 0 {
            handleNoteOn(UInt8(note), withVelocity: UInt8(vel))
        } else if (notif.name == AKMidiStatus.NoteOn.name() && vel == 0) || notif.name == AKMidiStatus.NoteOff.name() {
            handleNoteOff(UInt8(note))
        }
    }
    
    public func handleNoteOn(note: UInt8, withVelocity velocity: UInt8) {
        notesPlayed[voicePlaying] = Int(note)
        startVoice(voicePlaying, note: note, withVelocity: velocity)
        voicePlaying = (voicePlaying + 1) % voiceCount
    }
    
    public func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8) {
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity)")
    }
    
    public func handleNoteOff(note: UInt8) {
        var voiceToStop = notesPlayed.indexOf(Int(note))
        while(voiceToStop != nil) {
            stopVoice(voiceToStop!, note: note)
            notesPlayed[voiceToStop!] = 0
            voiceToStop = notesPlayed.indexOf(Int(note))
        }
    }
    
    public func stopVoice(voice: Int, note: UInt8) {
        print("Stopping voice\(voice) - note:\(note)")
    }
    
    public func panic() {
        for(var i = 0; i < voiceCount; i++) {
            voices[i].stop()
        }
    }    
}