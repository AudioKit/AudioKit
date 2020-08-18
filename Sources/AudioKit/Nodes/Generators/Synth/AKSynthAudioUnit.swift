// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public class AKSynthAudioUnit: AKAudioUnitBase {

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

    public override func createDSP() -> AKDSPRef {
        return akAKSynthCreateDSP()
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        var parameterAddress: AUParameterAddress = 0
        masterVolume = AUParameter(
            identifier: "masterVolume",
            name: "Master Volume",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        parameterAddress += 1

        pitchBend = AUParameter(
            identifier: "pitchBend",
            name: "Pitch Offset (semitones)",
            address: parameterAddress,
            range: -1_000.0...1_000.0,
            unit: .relativeSemiTones,
            flags: .default)

        parameterAddress += 1

        vibratoDepth = AUParameter(
            identifier: "vibratoDepth",
            name: "Vibrato amount (semitones)",
            address: parameterAddress,
            range: 0.0...24.0,
            unit: .relativeSemiTones,
            flags: .default)

        parameterAddress += 1

        filterCutoff = AUParameter(
            identifier: "filterCutoff",
            name: "Filter cutoff (harmonic))",
            address: parameterAddress,
            range: 1.0...1_000.0,
            unit: .ratio,
            flags: .default)

        parameterAddress += 1

        filterStrength = AUParameter(
            identifier: "filterStrength",
            name: "Filter EG strength",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .ratio,
            flags: .default)

        parameterAddress += 1

        filterResonance = AUParameter(
            identifier: "filterResonance",
            name: "Filter resonance (dB))",
            address: parameterAddress,
            range: -20.0...20.0,
            unit: .decibels,
            flags: .default)

        parameterAddress += 1

        attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Amplitude Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Amplitude Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        sustainLevel = AUParameter(
            identifier: "sustainLevel",
            name: "Amplitude Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        releaseDuration = AUParameter(
            identifier: "releaseDuration",
            name: "Amplitude Release duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        filterAttackDuration = AUParameter(
            identifier: "filterAttackDuration",
            name: "Filter Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        filterDecayDuration = AUParameter(
            identifier: "filterDecayDuration",
            name: "Filter Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        filterSustainLevel = AUParameter(
            identifier: "filterSustainLevel",
            name: "Filter Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        filterReleaseDuration = AUParameter(
            identifier: "filterReleaseDuration",
            name: "Filter Release duration (seconds)",
            address: parameterAddress,
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

    public func playNote(noteNumber: UInt8,
                         velocity: UInt8,
                         noteFrequency: Float) {
        akSynthPlayNote(dsp, noteNumber, velocity, noteFrequency)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        akSynthStopNote(dsp, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        akSynthSustainPedal(dsp, down)
    }
}
