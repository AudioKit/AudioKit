//
//  DrumSynths.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Kick Drum Synthesizer Instrument
public class AKSynthKick: AKPolyphonicInstrument {
    
    /// Create the synth kick instrument
    /// 
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    public init(voiceCount: Int) {
        super.init(voice: AKSynthKickVoice(), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override public func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override public func stopVoice(voice: AKVoice, note: Int) {
        
    }
}

/// Kick Drum Synthesizer Voice
internal class AKSynthKickVoice: AKVoice {
    var generator: AKOperationGenerator
    
    var filter: AKMoogLadder
    
    /// Create the synth kick voice
    override init() {
        
        let frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 40, duration: 0.03)
        let volumeSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: 0.3)
        let boom = AKOperation.sineWave(frequency: frequency, amplitude: volumeSlide)
        
        generator = AKOperationGenerator(operation: boom)
        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 666
        filter.resonance = 0.00
        
        super.init()
        avAudioNode = filter.avAudioNode
        generator.start()
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = AKSynthKickVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}

/// Snare Drum Synthesizer Instrument
public class AKSynthSnare: AKPolyphonicInstrument {
    
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    public init(voiceCount: Int, duration: Double = 0.143, resonance: Double = 0.9) {
        super.init(voice: AKSynthSnareVoice(duration: duration, resonance:resonance), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override public func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let tempVoice = voice as! AKSynthSnareVoice
        tempVoice.cutoff = (Double(velocity)/127.0 * 1600.0) + 300.0
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override public func stopVoice(voice: AKVoice, note: Int) {
        
    }
}

/// Snare Drum Synthesizer Voice
internal class AKSynthSnareVoice: AKVoice {
    
    var generator: AKOperationGenerator
    var filter: AKMoogLadder
    var duration = 0.143
    
    /// Create the synth snare voice
    init(duration: Double = 0.143, resonance: Double = 0.9) {
        self.duration = duration
        self.resonance = resonance
        
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: duration)
        let white = AKOperation.whiteNoise(amplitude: volSlide)
        generator = AKOperationGenerator(operation: white)
        
        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 1666
        
        super.init()
        avAudioNode = filter.avAudioNode
        generator.start()
    }
    
    internal var cutoff: Double = 1666 {
        didSet {
            filter.cutoffFrequency = cutoff
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
            filter.resonance = resonance
        }
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = AKSynthSnareVoice(duration: duration, resonance: resonance)
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}
