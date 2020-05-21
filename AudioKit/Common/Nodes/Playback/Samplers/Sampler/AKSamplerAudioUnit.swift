// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKSamplerAudioUnit: AKAudioUnitBase {

    var masterVolume: AUParameter!

    var pitchBend: AUParameter!

    var vibratoDepth: AUParameter!

    var vibratoFrequency: AUParameter!

    var filterCutoff: AUParameter!

    var filterStrength: AUParameter!

    var filterResonance: AUParameter!

    var glideRate: AUParameter!

    var attackDuration: AUParameter!

    var decayDuration: AUParameter!

    var sustainLevel: AUParameter!

    var releaseDuration: AUParameter!

    var filterAttackDuration: AUParameter!

    var filterDecayDuration: AUParameter!

    var filterSustainLevel: AUParameter!

    var filterReleaseDuration: AUParameter!

    var pitchAttackDuration: AUParameter!

    var pitchDecayDuration: AUParameter!

    var pitchSustainLevel: AUParameter!

    var pitchReleaseDuration: AUParameter!

    var pitchADSRSemitones: AUParameter!

    var filterEnable: AUParameter!

    var loopThruRelease: AUParameter!

    var isMonophonic: AUParameter!

    var isLegato: AUParameter!

    var keyTrackingFraction: AUParameter!

    var filterEnvelopeVelocityScaling: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createAKSamplerDSP()
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

        vibratoFrequency = AUParameter(
            identifier: "vibratoFrequency",
            name: "Vibrato Speed (hz)",
            address: parameterAddress,
            range: 0.0...200.0,
            unit: .hertz,
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

        glideRate = AUParameter(
            identifier: "glideRate",
            name: "Glide rate (sec/octave))",
            address: parameterAddress,
            range: 0.0...10.0,
            unit: .seconds,
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

        parameterAddress += 1

        filterEnable = AUParameter(
            identifier: "filterEnable",
            name: "Filter Enable",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        pitchAttackDuration = AUParameter(
            identifier: "pitchAttackDuration",
            name: "Pitch Attack duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        pitchDecayDuration = AUParameter(
            identifier: "pitchDecayDuration",
            name: "Pitch Decay duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        pitchSustainLevel = AUParameter(
            identifier: "pitchSustainLevel",
            name: "Pitch Sustain level (fraction)",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        pitchReleaseDuration = AUParameter(
            identifier: "pitchReleaseDuration",
            name: "Pitch Release duration (seconds)",
            address: parameterAddress,
            range: 0.0...1_000.0,
            unit: .seconds,
            flags: nonRampFlags)

        parameterAddress += 1

        pitchADSRSemitones = AUParameter(
            identifier: "pitchADSRSemitones",
            name: "Pitch EG Amount",
            address: parameterAddress,
            range: -100.0...100.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        loopThruRelease = AUParameter(
            identifier: "loopThruRelease",
            name: "Loop Thru Release",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        isMonophonic = AUParameter(
            identifier: "monophonic",
            name: "Monophonic Mode",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        isLegato = AUParameter(
            identifier: "legato",
            name: "Legato Mode",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .boolean,
            flags: nonRampFlags)

        parameterAddress += 1

        keyTrackingFraction = AUParameter(
            identifier: "keyTracking",
            name: "Key Tracking",
            address: parameterAddress,
            range: -2.0...2.0,
            unit: .generic,
            flags: nonRampFlags)

        parameterAddress += 1

        filterEnvelopeVelocityScaling = AUParameter(
            identifier: "filterEnvelopeVelocityScaling",
            name: "Filter Envelope Velocity Scaling",
            address: parameterAddress,
            range: 0.0...1.0,
            unit: .generic,
            flags: nonRampFlags)

        let children: [AUParameterNode] = [
            masterVolume,
            pitchBend,
            vibratoDepth,
            vibratoFrequency,
            filterCutoff,
            filterStrength,
            filterResonance,
            glideRate,
            attackDuration,
            decayDuration,
            sustainLevel,
            releaseDuration,
            filterAttackDuration,
            filterDecayDuration,
            filterSustainLevel,
            filterReleaseDuration,
            filterEnable,
            pitchAttackDuration,
            pitchDecayDuration,
            pitchSustainLevel,
            pitchReleaseDuration,
            pitchADSRSemitones,
            loopThruRelease,
            isMonophonic,
            isLegato,
            keyTrackingFraction,
            filterEnvelopeVelocityScaling]

        parameterTree = AUParameterTree.createTree(withChildren: children)

        masterVolume.value = 1.0
        pitchBend.value = 0.0
        vibratoDepth.value = 0.0
        vibratoFrequency.value = 5.0
        filterCutoff.value = 4.0
        filterStrength.value = 20.0
        filterResonance.value = 0.0
        glideRate.value = 0.0
        attackDuration.value = 0.0
        decayDuration.value = 0.0
        sustainLevel.value = 1.0
        releaseDuration.value = 0.0
        filterAttackDuration.value = 0.0
        filterDecayDuration.value = 0.0
        filterSustainLevel.value = 1.0
        filterReleaseDuration.value = 0.0
        filterEnable.value = 0.0
        pitchAttackDuration.value = 0.0
        pitchDecayDuration.value = 0.0
        pitchSustainLevel.value = 0.0
        pitchReleaseDuration.value = 0.0
        pitchADSRSemitones.value = 0.0
        loopThruRelease.value = 0.0
        isMonophonic.value = 0.0
        isLegato.value = 0.0
        keyTrackingFraction.value = 1.0
        filterEnvelopeVelocityScaling.value = 0.0
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

//    public override func shouldClearOutputBuffer() -> Bool {
//        return true
//    }
}
