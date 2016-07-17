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
public class AKSynthKick: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder

    /// Create the synth kick voice
    public override init() {

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
  
    /// Function to start, play, or activate the node, all do the same thing
    public override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        generator.trigger()
    }
}

/// Snare Drum Synthesizer Instrument
public class AKSynthSnare: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder
    var duration = 0.143

    /// Create the synth snare voice
    public init(duration: Double = 0.143, resonance: Double = 0.9) {
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
    
    
    /// Function to start, play, or activate the node, all do the same thing
    public override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        cutoff = (Double(velocity)/127.0 * 1600.0) + 300.0
        generator.trigger()
    }
}
