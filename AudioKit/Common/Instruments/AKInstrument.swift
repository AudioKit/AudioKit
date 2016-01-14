//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Parent class for nodes that can be included in a polyphonic instrument
public class AKVoice: AKNode, AKToggleable {
    
    /// Required for the AKToggleable protocol
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
    
    /// Return a duplication of this voice
    public func copy() -> AKVoice {
        return AKVoice()
        // override in subclass
    }
}

/// This class is for generator nodes that consist of a number of voices that 
/// can be played simultaneously for polyphony
public class AKPolyphonicInstrument: AKNode {

    /// Array of available voices
    public var voices: [AKVoice] = []
    
    var notesPlayed: [Int] = []
    
    var voicePlaying = 0
    var voiceCount = 1
    private let output = AKMixer()
    
    /// Output level
    public var volume: Double = 1.0 {
        didSet {
            output.volume = volume
        }
    }

    /// Alias for volume
    public var amplitude: Double = 1.0 {
        didSet {
            output.volume = volume
        }
    }
    
    /// Initialize the polyphonic instrument with a voice and a count
    ///
    /// - parameter voice: Template voice which will be copied
    /// - parameter voiceCount: Maximum number of simultaneous voices
    ///
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
    
    /// Start playback with MIDI style note and velocity
    ///
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    public func playNote(note: Int, velocity: Int) {
        notesPlayed[voicePlaying] = note
        playVoice(voicePlaying, note: note, velocity: velocity)
        voicePlaying = (voicePlaying + 1) % voiceCount
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Index of voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    public func playVoice(voice: Int, note: Int, velocity: Int) {
        // Override in subclass
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity)")
    }
    
    /// Stop playback of a particular note
    ///
    /// - parameter note: MIDI Note Number
    ///
    public func stopNote(note: Int) {
        var voiceToStop = notesPlayed.indexOf(note)
        while(voiceToStop != nil) {
            stopVoice(voiceToStop!, note: note)
            notesPlayed[voiceToStop!] = 0
            voiceToStop = notesPlayed.indexOf(note)
        }
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Index of voice to stop
    /// - parameter note: MIDI Note Number
    ///
    public func stopVoice(voice: Int, note: Int) {
        /// Override in subclass
        print("Stopping voice\(voice) - note:\(note)")
    }
    
    /// Stop all voices
    public func panic() {
        for(var i = 0; i < voiceCount; i++) {
            voices[i].stop()
        }
    }    
}