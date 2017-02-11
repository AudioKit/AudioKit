//
//  DrumSynths.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Kick Drum Synthesizer Instrument
open class AKSynthKick: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder

    /// Create the synth kick voice
    public override init() {

        generator = AKOperationGenerator { _ in
            let frequency = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 120, end: 40, duration: 0.03)
            let volumeSlide = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 1, end: 0, duration: 0.3)
            return AKOperation.sineWave(frequency: frequency, amplitude: volumeSlide)
        }

        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 666
        filter.resonance = 0.00

        super.init()
        avAudioNode = filter.avAudioNode
        generator.start()
    }

    /// Function to start, play, or activate the node, all do the same thing
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    open override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }
}

/// Snare Drum Synthesizer Instrument
open class AKSynthSnare: AKMIDIInstrument {

    var generator: AKOperationGenerator
    var filter: AKMoogLadder
    var duration = 0.143

    /// Create the synth snare voice
    public init(duration: Double = 0.143, resonance: Double = 0.9) {
        self.duration = duration
        self.resonance = resonance

        generator = AKOperationGenerator { _ in
            let volSlide = AKOperation.lineSegment(
                trigger: AKOperation.trigger,
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.whiteNoise(amplitude: volSlide)
        }

        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 1_666

        super.init()
        avAudioNode = filter.avAudioNode
        generator.start()
    }

    internal var cutoff: Double = 1_666 {
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
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        cutoff = (Double(velocity) / 127.0 * 1_600.0) + 300.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    open override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }

}
