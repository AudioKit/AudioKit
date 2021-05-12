// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// Kick Drum Synthesizer Instrument
public class SynthKick: MIDIInstrument {

    var generator: OperationGenerator

    /// Create the synth kick voice
    ///
    /// - Parameter midiInputName: Name of the instrument's MIDI input.
    public override init(midiInputName: String? = nil) {

        generator = OperationGenerator {
            let frequency = Operation.lineSegment(trigger: Operation.trigger, start: 120, end: 40, duration: 0.03)
            let volumeSlide = Operation.lineSegment(trigger: Operation.trigger, start: 1, end: 0, duration: 0.3)
            return Operation.sineWave(frequency: frequency, amplitude: volumeSlide)
                .moogLadderFilter(cutoffFrequency: Operation.parameters[0],
                                  resonance: Operation.parameters[1])
        }

        super.init(midiInputName: midiInputName)
        avAudioNode = generator.avAudioNode
        generator.start()
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        generator.parameter1 = (AUValue(velocity) / 127.0 * 366.0) + 300.0
        generator.parameter2 = 1.0 - AUValue(velocity) / 127.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    public func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel = 0) {
        // Unneeded
    }
}

/// Snare Drum Synthesizer Instrument
public class SynthSnare: MIDIInstrument {

    var generator: OperationGenerator
    var duration = 0.143

    /// Create the synth snare voice
    public init(duration: Double = 0.143, resonance: AUValue = 0.9) {
        self.duration = duration
        self.resonance = resonance

        generator = OperationGenerator {
            let volSlide = Operation.lineSegment(
                trigger: Operation.trigger,
                start: 1,
                end: 0,
                duration: duration)
            return Operation.whiteNoise(amplitude: volSlide)
                .moogLadderFilter(cutoffFrequency: Operation.parameters[0],
                                  resonance: Operation.parameters[1])
        }

        super.init()
        avAudioNode = generator.avAudioNode
        generator.start()
    }

    internal var cutoff: AUValue = 1_666 {
        didSet {
            generator.parameter1 = cutoff
        }
    }
    internal var resonance: AUValue = 0.3 {
        didSet {
            generator.parameter2 = resonance
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        generator.parameter1 = (AUValue(velocity) / 127.0 * 1_600.0) + 300.0
        generator.trigger()
    }

    /// Unneeded stop function since the sounds all decay quickly
    public func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel = 0) {
        // Unneeded
    }
}

#endif
