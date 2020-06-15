//
//  AKSamplerAudioUnit.swift
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKSamplerAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKSamplerParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKSamplerParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var masterVolume: Double = 0.0 {
        didSet { setParameter(.masterVolume, value: masterVolume) }
    }

    var pitchBend: Double = 0.0 {
        didSet { setParameter(.pitchBend, value: pitchBend) }
    }

    var vibratoDepth: Double = 0.0 {
        didSet { setParameter(.vibratoDepth, value: vibratoDepth) }
    }

    var vibratoFrequency: Double = 5.0 {
        didSet { setParameter(.vibratoFrequency, value: vibratoFrequency) }
    }

    var voiceVibratoDepth: Double = 0.0 {
        didSet { setParameter(.voiceVibratoDepth, value: voiceVibratoDepth) }
    }

    var voiceVibratoFrequency: Double = 5.0 {
        didSet { setParameter(.voiceVibratoFrequency, value: voiceVibratoFrequency) }
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

    var glideRate: Double = 0.0 {
        didSet { setParameter(.glideRate, value: glideRate) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    var attackDuration: Double = 0.0 {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var holdDuration: Double = 0.0 {
        didSet { setParameter(.holdDuration, value: holdDuration) }
    }

    var decayDuration: Double = 0.0 {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var sustainLevel: Double = 0.0 {
        didSet { setParameter(.sustainLevel, value: sustainLevel) }
    }

    var releaseHoldDuration: Double = 0.0 {
        didSet { setParameter(.releaseHoldDuration, value: releaseHoldDuration) }
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

    var pitchAttackDuration: Double = 0.0 {
        didSet { setParameter(.pitchAttackDuration, value: pitchAttackDuration) }
    }

    var pitchDecayDuration: Double = 0.0 {
        didSet { setParameter(.pitchDecayDuration, value: pitchDecayDuration) }
    }

    var pitchSustainLevel: Double = 0.0 {
        didSet { setParameter(.pitchSustainLevel, value: pitchSustainLevel) }
    }

    var pitchReleaseDuration: Double = 0.0 {
        didSet { setParameter(.pitchReleaseDuration, value: pitchReleaseDuration) }
    }

    var pitchADSRSemitones: Double = 0.0 {
        didSet { setParameter(.pitchADSRSemitones, value: pitchADSRSemitones) }
    }

    var restartVoiceLFO: Double = 0.0 {
        didSet { setParameter(.restartVoiceLFO, value: restartVoiceLFO) }
    }

    var filterEnable: Double = 0.0 {
        didSet { setParameter(.filterEnable, value: filterEnable) }
    }

    var loopThruRelease: Double = 0.0 {
        didSet { setParameter(.loopThruRelease, value: loopThruRelease) }
    }

    var isMonophonic: Double = 0.0 {
        didSet { setParameter(.monophonic, value: isMonophonic) }
    }

    var isLegato: Double = 0.0 {
        didSet { setParameter(.legato, value: isLegato) }
    }

    var keyTrackingFraction: Double = 1.0 {
        didSet { setParameter(.keyTrackingFraction, value: keyTrackingFraction) }
    }

    var filterEnvelopeVelocityScaling: Double = 0.0 {
        didSet { setParameter(.filterEnvelopeVelocityScaling, value: filterEnvelopeVelocityScaling) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAKSamplerDSP(Int32(count), sampleRate)
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

        let vibratoFrequencyParameter = AUParameter(
            identifier: "vibratoFrequency",
            name: "Vibrato Speed (hz)",
            address: parameterAddress,
            range: 0.0...200.0,
            unit: .hertz,
            flags: .default)

        parameterAddress += 1

        let voiceVibratoDepthParameter = AUParameter(
            identifier: "voiceVibratoDepth",
            name: "Per-Voice Vibrato amount (semitones)",
            address: parameterAddress,
            range: 0.0...24.0,
            unit: .relativeSemiTones,
            flags: .default)

        parameterAddress += 1

        let voiceVibratoFrequencyParameter = AUParameter(
            identifier: "voiceVibratoFrequency",
            name: "Per-Voice Vibrato Speed (hz)",
            address: parameterAddress,
            range: 0.0...200.0,
            unit: .hertz,
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

        let glideRateParameter = AUParameter(
            identifier: "glideRate",
            name: "Glide rate (sec/octave))",
            address: parameterAddress,
            range: 0.0...10.0,
            unit: .seconds,
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

        let holdDurationParameter = AUParameter(
            identifier: "holdDuration",
            name: "Amplitude Hold duration (seconds)",
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

        let releaseHoldDurationParameter = AUParameter(
            identifier: "releaseHoldDuration",
            name: "Amplitude Release-Hold duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
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

        parameterAddress += 1

        let filterEnableParameter = AUParameter(
            identifier: "filterEnable",
            name: "Filter Enable",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        let restartVoiceLFOParameter = AUParameter(
            identifier: "restartVoiceLFO",
            name: "Restart Voice LFO",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        let pitchAttackDurationParameter = AUParameter(
            identifier: "pitchAttackDuration",
            name: "Pitch Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let pitchDecayDurationParameter = AUParameter(
            identifier: "pitchDecayDuration",
            name: "Pitch Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let pitchSustainLevelParameter = AUParameter(
            identifier: "pitchSustainLevel",
            name: "Pitch Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        let pitchReleaseDurationParameter = AUParameter(
            identifier: "pitchReleaseDuration",
            name: "Pitch Release duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        let pitchADSRSemitonesParameter = AUParameter(
            identifier: "pitchADSRSemitones",
            name: "Pitch EG Amount",
            address: parameterAddress,
            range: -100.0...100.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        let loopThruReleaseParameter = AUParameter(
            identifier: "loopThruRelease",
            name: "Loop Thru Release",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        let monophonicParameter = AUParameter(
            identifier: "monophonic",
            name: "Monophonic Mode",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        let legatoParameter = AUParameter(
            identifier: "legato",
            name: "Legato Mode",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        let keyTrackingParameter = AUParameter(
            identifier: "keyTracking",
            name: "Key Tracking",
            address: parameterAddress,
            range: -2.0...2.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        let filterEnvelopeVelocityScalingParameter = AUParameter(
            identifier: "filterEnvelopeVelocityScaling",
            name: "Filter Envelope Velocity Scaling",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        setParameterTree(AUParameterTree(children: [masterVolumeParameter,
                                                                   pitchBendParameter,
                                                                   vibratoDepthParameter,
                                                                   vibratoFrequencyParameter,
                                                                   voiceVibratoDepthParameter,
                                                                   voiceVibratoFrequencyParameter,
                                                                   filterCutoffParameter,
                                                                   filterStrengthParameter,
                                                                   filterResonanceParameter,
                                                                   glideRateParameter,
                                                                   attackDurationParameter,
                                                                   holdDurationParameter,
                                                                   decayDurationParameter,
                                                                   sustainLevelParameter,
                                                                   releaseHoldDurationParameter,
                                                                   releaseDurationParameter,
                                                                   filterAttackDurationParameter,
                                                                   filterDecayDurationParameter,
                                                                   filterSustainLevelParameter,
                                                                   filterReleaseDurationParameter,
                                                                   filterEnableParameter,
                                                                   restartVoiceLFOParameter,
                                                                   pitchAttackDurationParameter,
                                                                   pitchDecayDurationParameter,
                                                                   pitchSustainLevelParameter,
                                                                   pitchReleaseDurationParameter,
                                                                   pitchADSRSemitonesParameter,
                                                                   loopThruReleaseParameter,
                                                                   monophonicParameter,
                                                                   legatoParameter,
                                                                   keyTrackingParameter,
                                                                   filterEnvelopeVelocityScalingParameter]))
        masterVolumeParameter.value = 1.0
        pitchBendParameter.value = 0.0
        vibratoDepthParameter.value = 0.0
        vibratoFrequencyParameter.value = 5.0
        voiceVibratoDepthParameter.value = 0.0
        voiceVibratoFrequencyParameter.value = 5.0
        filterCutoffParameter.value = 4.0
        filterStrengthParameter.value = 20.0
        filterResonanceParameter.value = 0.0
        glideRateParameter.value = 0.0
        attackDurationParameter.value = 0.0
        holdDurationParameter.value = 0.0
        decayDurationParameter.value = 0.0
        sustainLevelParameter.value = 1.0
        releaseHoldDurationParameter.value = 0.0
        releaseDurationParameter.value = 0.0
        filterAttackDurationParameter.value = 0.0
        filterDecayDurationParameter.value = 0.0
        filterSustainLevelParameter.value = 1.0
        filterReleaseDurationParameter.value = 0.0
        filterEnableParameter.value = 0.0
        restartVoiceLFOParameter.value = 0.0
        pitchAttackDurationParameter.value = 0.0
        pitchDecayDurationParameter.value = 0.0
        pitchSustainLevelParameter.value = 0.0
        pitchReleaseDurationParameter.value = 0.0
        pitchADSRSemitonesParameter.value = 0.0
        loopThruReleaseParameter.value = 0.0
        monophonicParameter.value = 0.0
        legatoParameter.value = 0.0
        keyTrackingParameter.value = 1.0
        filterEnvelopeVelocityScalingParameter.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true }

    public func stopAllVoices() {
        doAKSamplerStopAllVoices(dsp)
    }

    public func restartVoices() {
        doAKSamplerRestartVoices(dsp)
    }

    public func loadSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        var copy = sampleDataDescriptor
        doAKSamplerLoadData(dsp, &copy)
    }

    public func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        var copy = sampleFileDescriptor
        doAKSamplerLoadCompressedFile(dsp, &copy)
    }

    public func unloadAllSamples() {
        doAKSamplerUnloadAllSamples(dsp)
    }

    public func setNoteFrequency(noteNumber: Int32, noteFrequency: Float) {
        doAKSamplerSetNoteFrequency(dsp, noteNumber, noteFrequency)
    }

    public func buildSimpleKeyMap() {
        doAKSamplerBuildSimpleKeyMap(dsp)
    }

    public func buildKeyMap() {
        doAKSamplerBuildKeyMap(dsp)
    }

    public func setLoop(thruRelease: Bool) {
        doAKSamplerSetLoopThruRelease(dsp, thruRelease)
    }

    public func playNote(noteNumber: UInt8, velocity: UInt8) {
        doAKSamplerPlayNote(dsp, noteNumber, velocity)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAKSamplerStopNote(dsp, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        doAKSamplerSustainPedal(dsp, down)
    }

    public override func shouldClearOutputBuffer() -> Bool {
        return true
    }

}
