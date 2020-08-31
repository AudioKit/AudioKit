// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// Kick Drum Synthesizer Instrument
public class AKSynthKick: AKMIDIInstrument {

    var generator: AKOperationGenerator
//    var filter: AKMoogLadder

    /// Create the synth kick voice
    ///
    /// - Parameter midiInputName: Name of the instrument's MIDI input.
    public override init(midiInputName: String? = nil) {

        generator = AKOperationGenerator {
            let frequency = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 120, end: 40, duration: 0.03)
            let volumeSlide = AKOperation.lineSegment(trigger: AKOperation.trigger, start: 1, end: 0, duration: 0.3)
            return AKOperation.sineWave(frequency: frequency, amplitude: volumeSlide)
        }

        // TODO FIXME
//        filter = AKMoogLadder(generator)
//        filter.cutoffFrequency = 666
//        filter.resonance = 0.00

        super.init(midiInputName: midiInputName)
//        avAudioUnit = filter.avAudioUnit
        generator.start()
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
//        filter.cutoffFrequency = (AUValue(velocity) / 127.0 * 366.0) + 300.0
//        filter.resonance = 1.0 - AUValue(velocity) / 127.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    public override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }
}

/// Snare Drum Synthesizer Instrument
public class AKSynthSnare: AKMIDIInstrument {

    var generator: AKOperationGenerator
//    var filter: AKMoogLadder
    var duration = 0.143

    /// Create the synth snare voice
    public init(duration: Double = 0.143, resonance: Double = 0.9) {
        self.duration = duration
        self.resonance = resonance

        generator = AKOperationGenerator {
            let volSlide = AKOperation.lineSegment(
                trigger: AKOperation.trigger,
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.whiteNoise(amplitude: volSlide)
        }
// TODO FIXME
//        filter = AKMoogLadder(generator)
//        filter.cutoffFrequency = AUValue(1_666)

        super.init()
//        avAudioUnit = filter.avAudioUnit
        generator.start()
    }

    internal var cutoff: Double = 1_666 {
        didSet {
//            filter.cutoffFrequency = AUValue(cutoff)
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
//            filter.resonance = AUValue(resonance)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        cutoff = (Double(velocity) / 127.0 * 1_600.0) + 300.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    public override func stop(noteNumber: MIDINoteNumber) {
        // Unneeded
    }
}

#endif
