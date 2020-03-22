//
//  AKSynthAudioUnit.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AVFoundation

public class AKSynthAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKSynthParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKSynthParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var masterVolume: Double = 0.0 {
        didSet { setParameter(.masterVolume, value: masterVolume) }
    }

    var pitchBend: Double = 0.0 {
        didSet { setParameter(.pitchBend, value: pitchBend) }
    }

    var vibratoDepth: Double = 1.0 {
        didSet { setParameter(.vibratoDepth, value: vibratoDepth) }
    }

    var filterCutoff: Double = 4.0 {
        didSet { setParameter(.filterCutoff, value: filterCutoff) }
    }

    var filterStrength: Double = 20.0 {
        didSet { setParameter(.filterStrength, value: filterCutoff) }
    }

    var filterResonance: Double = 0.0 {
        didSet { setParameter(.filterResonance, value: filterResonance) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    var attackDuration: Double = 0.0 {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var decayDuration: Double = 0.0 {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var sustainLevel: Double = 0.0 {
        didSet { setParameter(.sustainLevel, value: sustainLevel) }
    }

    var releaseDuration: Double = 0.0 {
        didSet { setParameter(.releaseDuration, value: releaseDuration) }
    }

    var filterAttackDuration: Double = 0.0 {
        didSet { setParameter(.filterAttackDuration, value: filterAttackDuration) }
    }

    var filterDecayDuration: Double = 0.0 {
        didSet { setParameter(.filterDecayDuration, value: filterDecayDuration) }
    }

    var filterSustainLevel: Double = 0.0 {
        didSet { setParameter(.filterSustainLevel, value: filterSustainLevel) }
    }

    var filterReleaseDuration: Double = 0.0 {
        didSet { setParameter(.filterReleaseDuration, value: filterReleaseDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAKSynthDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        var parameterAddress: AUParameterAddress = 0
        let masterVolumeParameter = AUParameter(
            identifier: "masterVolume",
            name: "Master Volume",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        parameterAddress += 1

        let pitchBendParameter = AUParameter(
            identifier: "pitchBend",
            name: "Pitch Offset (semitones)",
            address: parameterAddress,
            range: -1_000.0...1_000.0,
            unit: .relativeSemiTones,
            flags: .default)

        parameterAddress += 1

        let vibratoDepthParameter = AUParameter(
            identifier: "vibratoDepth",
            name: "Vibrato amount (semitones)",
            address: parameterAddress,
            range: 0.0...24.0,
            unit: .relativeSemiTones,
            flags: .default)

        parameterAddress += 1

        let filterCutoffParameter = AUParameter(
            identifier: "filterCutoff",
            name: "Filter cutoff (harmonic))",
            address: parameterAddress,
            range: 1.0...1_000.0,
            unit: .ratio,
            flags: .default)

        parameterAddress += 1

        let filterStrengthParameter = AUParameter(
            identifier: "filterStrength",
            name: "Filter EG strength",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .ratio,
            flags: .default)

        parameterAddress += 1

        let filterResonanceParameter = AUParameter(
            identifier: "filterResonance",
            name: "Filter resonance (dB))",
            address: parameterAddress,
            range: -20.0...20.0,
            unit: .decibels,
            flags: .default)

        parameterAddress += 1

        let attackDurationParameter = AUParameter(
            identifier: "attackDuration",
            name: "Amplitude Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let decayDurationParameter = AUParameter(
            identifier: "decayDuration",
            name: "Amplitude Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let sustainLevelParameter = AUParameter(
            identifier: "sustainLevel",
            name: "Amplitude Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        let releaseDurationParameter = AUParameter(
            identifier: "releaseDuration",
            name: "Amplitude Release duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let filterAttackDurationParameter = AUParameter(
            identifier: "filterAttackDuration",
            name: "Filter Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let filterDecayDurationParameter = AUParameter(
            identifier: "filterDecayDuration",
            name: "Filter Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let filterSustainLevelParameter = AUParameter(
            identifier: "filterSustainLevel",
            name: "Filter Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        let filterReleaseDurationParameter = AUParameter(
            identifier: "filterReleaseDuration",
            name: "Filter Release duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        setParameterTree(AUParameterTree(children: [
            masterVolumeParameter,
            pitchBendParameter,
            vibratoDepthParameter,
            filterCutoffParameter,
            filterStrengthParameter,
            filterResonanceParameter,
            attackDurationParameter,
            decayDurationParameter,
            sustainLevelParameter,
            releaseDurationParameter,
            filterAttackDurationParameter,
            filterDecayDurationParameter,
            filterSustainLevelParameter,
            filterReleaseDurationParameter
            ]))

        masterVolumeParameter.value = 1.0
        pitchBendParameter.value = 0.0
        vibratoDepthParameter.value = 0.0
        filterCutoffParameter.value = 4.0
        filterStrengthParameter.value = 20.0
        filterResonanceParameter.value = 0.0
        attackDurationParameter.value = 0.0
        decayDurationParameter.value = 0.0
        sustainLevelParameter.value = 1.0
        releaseDurationParameter.value = 0.0
        filterAttackDurationParameter.value = 0.0
        filterDecayDurationParameter.value = 0.0
        filterSustainLevelParameter.value = 1.0
        filterReleaseDurationParameter.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true }

    public func playNote(noteNumber: UInt8,
                         velocity: UInt8,
                         noteFrequency: Float) {
        doAKSynthPlayNote(dsp, noteNumber, velocity, noteFrequency)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAKSynthStopNote(dsp, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        doAKSynthSustainPedal(dsp, down)
    }

    public override func shouldClearOutputBuffer() -> Bool {
        return true
    }

}
