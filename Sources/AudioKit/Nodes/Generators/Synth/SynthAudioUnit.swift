// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Synth Audio Unit 
public class SynthAudioUnit: AudioUnitBase {

    var masterVolume: AUParameter!

    var pitchBend: AUParameter!

    var vibratoDepth: AUParameter!

    var filterCutoff: AUParameter!

    var filterStrength: AUParameter!

    var filterResonance: AUParameter!

    var attackDuration: AUParameter!

    var decayDuration: AUParameter!

    var sustainLevel: AUParameter!

    var releaseDuration: AUParameter!

    var filterAttackDuration: AUParameter!

    var filterDecayDuration: AUParameter!

    var filterSustainLevel: AUParameter!

    var filterReleaseDuration: AUParameter!

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        masterVolume = AUParameter(
            identifier: "masterVolume",
            name: "Master Volume",
            address: akGetParameterAddress("SynthParameterMasterVolume"),
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        pitchBend = AUParameter(
            identifier: "pitchBend",
            name: "Pitch Offset (semitones)",
            address: akGetParameterAddress("SynthParameterPitchBend"),
            range: -1_000.0...1_000.0,
            unit: .relativeSemiTones,
            flags: .default)

        vibratoDepth = AUParameter(
            identifier: "vibratoDepth",
            name: "Vibrato amount (semitones)",
            address: akGetParameterAddress("SynthParameterVibratoDepth"),
            range: 0.0...24.0,
            unit: .relativeSemiTones,
            flags: .default)

        filterCutoff = AUParameter(
            identifier: "filterCutoff",
            name: "Filter cutoff (harmonic))",
            address: akGetParameterAddress("SynthParameterFilterCutoff"),
            range: 1.0...1_000.0,
            unit: .ratio,
            flags: .default)

        filterStrength = AUParameter(
            identifier: "filterStrength",
            name: "Filter EG strength",
            address: akGetParameterAddress("SynthParameterFilterStrength"),
            range: 0.0...1_000.0,
            unit: .ratio,
            flags: .default)

        filterResonance = AUParameter(
            identifier: "filterResonance",
            name: "Filter resonance (dB))",
            address: akGetParameterAddress("SynthParameterFilterResonance"),
            range: -20.0...20.0,
            unit: .decibels,
            flags: .default)
    
        attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Amplitude Attack duration (seconds)",
            address: akGetParameterAddress("SynthParameterAttackDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Amplitude Decay duration (seconds)",
            address: akGetParameterAddress("SynthParameterDecayDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        sustainLevel = AUParameter(
            identifier: "sustainLevel",
            name: "Amplitude Sustain level (fraction)",
            address: akGetParameterAddress("SynthParameterSustainLevel"),
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        releaseDuration = AUParameter(
            identifier: "releaseDuration",
            name: "Amplitude Release duration (seconds)",
            address: akGetParameterAddress("SynthParameterReleaseDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        filterAttackDuration = AUParameter(
            identifier: "filterAttackDuration",
            name: "Filter Attack duration (seconds)",
            address: akGetParameterAddress("SynthParameterFilterAttackDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        filterDecayDuration = AUParameter(
            identifier: "filterDecayDuration",
            name: "Filter Decay duration (seconds)",
            address: akGetParameterAddress("SynthParameterFilterDecayDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        filterSustainLevel = AUParameter(
            identifier: "filterSustainLevel",
            name: "Filter Sustain level (fraction)",
            address: akGetParameterAddress("SynthParameterFilterSustainLevel"),
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        filterReleaseDuration = AUParameter(
            identifier: "filterReleaseDuration",
            name: "Filter Release duration (seconds)",
            address: akGetParameterAddress("SynthParameterFilterReleaseDuration"),
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterTree = AUParameterTree.createTree(withChildren: [
            masterVolume,
            pitchBend,
            vibratoDepth,
            filterCutoff,
            filterStrength,
            filterResonance,
            attackDuration,
            decayDuration,
            sustainLevel,
            releaseDuration,
            filterAttackDuration,
            filterDecayDuration,
            filterSustainLevel,
            filterReleaseDuration
            ])

        masterVolume.value = 1.0
        pitchBend.value = 0.0
        vibratoDepth.value = 0.0
        filterCutoff.value = 4.0
        filterStrength.value = 20.0
        filterResonance.value = 0.0
        attackDuration.value = 0.0
        decayDuration.value = 0.0
        sustainLevel.value = 1.0
        releaseDuration.value = 0.0
        filterAttackDuration.value = 0.0
        filterDecayDuration.value = 0.0
        filterSustainLevel.value = 1.0
        filterReleaseDuration.value = 0.0
    }

    public func scheduleMIDIEvent(event: MIDIEvent, offset: UInt64 = 0) {
        if let midiBlock = scheduleMIDIEventBlock {
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate + AUEventSampleTime(offset), 0, event.data.count, ptr)
            }
        }
    }

    /// Play a note
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: MIDI Velocity
    public func playNote(noteNumber: MIDINoteNumber,
                         velocity: MIDIVelocity) {
        scheduleMIDIEvent(event: MIDIEvent(noteOn: noteNumber, velocity: velocity, channel: 0))
    }

    /// Stop a note
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - immediate: Stop and allow to release or stop immediately
    public func stopNote(noteNumber: MIDINoteNumber, immediate: Bool) {
        scheduleMIDIEvent(event: MIDIEvent(noteOff: noteNumber, velocity: 0, channel: 0))
    }

    /// Set the sustain pedal position
    /// - Parameter down: True for pedal activation
    public func sustainPedal(down: Bool) {
        // XXX: send midi
    }
}
