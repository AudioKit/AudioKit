//
//  DrumSynths.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Kick Drum Synthesizer Instrument
public class AKDrumSynthKickInst: AKPolyphonicInstrument {
    public init(voiceCount: Int) {
        super.init(voice: AKDrumSynthKickVoice(), voiceCount: voiceCount)
    }
    override public func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    override public func stopVoice(voice: AKVoice, note: Int) {
        
    }
}
/// Kick Drum Synthesizer Voice
public class AKDrumSynthKickVoice:AKVoice{
    var generator:AKOperationGenerator
    var filt: AKMoogLadder?
    
    override public init() {
        
        let frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 40, duration: 0.03)
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: 0.3)
        let sine = AKOperation.sineWave(frequency: frequency, amplitude: volSlide)
        
        generator = AKOperationGenerator(operation: sine)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 666
        filt!.resonance = 0.00
        
        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override public func copy() -> AKVoice {
        let copy = AKDrumSynthKickVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override public func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override public func stop() {
        
    }
}

/// Snare Drum Synthesizer Instrument
public class AKDrumSynthSnareInst: AKPolyphonicInstrument {
    public init(voiceCount: Int, dur: Double = 0.143, res:Double = 0.9) {
        super.init(voice: AKDrumSynthSnareVoice(dur: dur, res:res), voiceCount: voiceCount)
    }
    override public func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let tempVoice = voice as! AKDrumSynthSnareVoice
        tempVoice.cutoff = (Double(velocity)/127.0 * 1600.0) + 300.0
        voice.start()
    }
    override public func stopVoice(voice: AKVoice, note: Int) {
        
    }
}

/// Snare Drum Synthesizer Voice
public class AKDrumSynthSnareVoice:AKVoice{
    var generator:AKOperationGenerator
    var filt: AKMoogLadder?
    var len = 0.143
    
    public init(dur:Double = 0.143, res:Double = 0.9) {
        print("dur \(dur)")
        len = dur
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: len)
        
        let white = AKOperation.whiteNoise(amplitude: volSlide)
        generator = AKOperationGenerator(operation: white)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 1666
        resonance = res
        
        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }
    
    internal var cutoff: Double = 1666 {
        didSet {
            filt?.cutoffFrequency = cutoff
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
            filt?.resonance = resonance
        }
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override public func copy() -> AKVoice {
        let copy = AKDrumSynthSnareVoice(dur: len, res:resonance)
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override public func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override public func stop() {
        
    }
}