// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit
import AVFoundation

/// Sampler's Audio Unit - not yet converted to an internal AU
public class SamplerAudioUnit: AudioUnitBase {
    private static var nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

    private static var _parameterAddress: AUParameterAddress = 0
    private static var nextAddress: AUParameterAddress {
        let out = _parameterAddress
        _parameterAddress += 1
        return out
    }

    var masterVolume = AUParameter(
        identifier: "masterVolume",
        name: "Master Volume",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .generic,
        flags: .default)

    var pitchBend = AUParameter(
        identifier: "pitchBend",
        name: "Pitch Offset (semitones)",
        address: nextAddress,
        range: -1_000.0...1_000.0,
        unit: .relativeSemiTones,
        flags: .default)

    var vibratoDepth = AUParameter(
        identifier: "vibratoDepth",
        name: "Vibrato amount (semitones)",
        address: nextAddress,
        range: 0.0...24.0,
        unit: .relativeSemiTones,
        flags: .default)

    var vibratoFrequency = AUParameter(
        identifier: "vibratoFrequency",
        name: "Vibrato Speed (hz)",
        address: nextAddress,
        range: 0.0...200.0,
        unit: .hertz,
        flags: .default)

    var voiceVibratoDepth = AUParameter(
        identifier: "voiceVibratoDepth",
        name: "Voice Vibrato amount (semitones)",
        address: nextAddress,
        range: 0.0...24.0,
        unit: .relativeSemiTones,
        flags: .default)

    var voiceVibratoFrequency = AUParameter(
        identifier: "voiceVibratoFrequency",
        name: "Voice Vibrato Speed (hz)",
        address: nextAddress,
        range: 0.0...200.0,
        unit: .hertz,
        flags: .default)

    var filterCutoff = AUParameter(
        identifier: "filterCutoff",
        name: "Filter cutoff (harmonic))",
        address: nextAddress,
        range: 1.0...1_000.0,
        unit: .ratio,
        flags: .default)

    var filterStrength = AUParameter(
        identifier: "filterStrength",
        name: "Filter EG strength",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .ratio,
        flags: .default)

    var filterResonance = AUParameter(
        identifier: "filterResonance",
        name: "Filter resonance (dB))",
        address: nextAddress,
        range: -20.0...20.0,
        unit: .decibels,
        flags: .default)

    var glideRate = AUParameter(
        identifier: "glideRate",
        name: "Glide rate (sec/octave))",
        address: nextAddress,
        range: 0.0...10.0,
        unit: .seconds,
        flags: .default)

    var attackDuration = AUParameter(
        identifier: "attackDuration",
        name: "Amplitude Attack duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var holdDuration = AUParameter(
        identifier: "holdDuration",
        name: "Amplitude Hold duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var decayDuration = AUParameter(
        identifier: "decayDuration",
        name: "Amplitude Decay duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var sustainLevel = AUParameter(
        identifier: "sustainLevel",
        name: "Amplitude Sustain level (fraction)",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .generic,
        flags: nonRampFlags)

    var releaseHoldDuration = AUParameter(
        identifier: "releaseHoldDuration",
        name: "Amplitude Release Hold duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var releaseDuration = AUParameter(
        identifier: "releaseDuration",
        name: "Amplitude Release duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var filterAttackDuration = AUParameter(
        identifier: "filterAttackDuration",
        name: "Filter Attack duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var filterDecayDuration = AUParameter(
        identifier: "filterDecayDuration",
        name: "Filter Decay duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var filterSustainLevel = AUParameter(
        identifier: "filterSustainLevel",
        name: "Filter Sustain level (fraction)",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .generic,
        flags: nonRampFlags)

    var filterReleaseDuration = AUParameter(
        identifier: "filterReleaseDuration",
        name: "Filter Release duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var filterEnable = AUParameter(
        identifier: "filterEnable",
        name: "Filter Enable",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .boolean,
        flags: nonRampFlags)

    var restartVoiceLFO = AUParameter(
        identifier: "restartVoiceLFO",
        name: "Restart Voice LFO",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .boolean,
        flags: nonRampFlags)

    var pitchAttackDuration = AUParameter(
        identifier: "pitchAttackDuration",
        name: "Pitch Attack duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var pitchDecayDuration = AUParameter(
        identifier: "pitchDecayDuration",
        name: "Pitch Decay duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var pitchSustainLevel = AUParameter(
        identifier: "pitchSustainLevel",
        name: "Pitch Sustain level (fraction)",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .generic,
        flags: nonRampFlags)

    var pitchReleaseDuration = AUParameter(
        identifier: "pitchReleaseDuration",
        name: "Pitch Release duration (seconds)",
        address: nextAddress,
        range: 0.0...1_000.0,
        unit: .seconds,
        flags: nonRampFlags)

    var pitchADSRSemitones = AUParameter(
        identifier: "pitchADSRSemitones",
        name: "Pitch EG Amount",
        address: nextAddress,
        range: -100.0...100.0,
        unit: .generic,
        flags: nonRampFlags)

    var loopThruRelease = AUParameter(
        identifier: "loopThruRelease",
        name: "Loop Thru Release",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .boolean,
        flags: nonRampFlags)

    var isMonophonic = AUParameter(
        identifier: "monophonic",
        name: "Monophonic Mode",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .boolean,
        flags: nonRampFlags)

    var isLegato = AUParameter(
        identifier: "legato",
        name: "Legato Mode",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .boolean,
        flags: nonRampFlags)

    var keyTrackingFraction = AUParameter(
        identifier: "keyTracking",
        name: "Key Tracking",
        address: nextAddress,
        range: -2.0...2.0,
        unit: .generic,
        flags: nonRampFlags)

    var filterEnvelopeVelocityScaling = AUParameter(
        identifier: "filterEnvelopeVelocityScaling",
        name: "Filter Envelope Velocity Scaling",
        address: nextAddress,
        range: 0.0...1.0,
        unit: .generic,
        flags: nonRampFlags)

    /// Create Sampler DSP
    /// - Returns: Reference to Sampler DSP Object
    public override func createDSP() -> DSPRef {
        return akSamplerCreateDSP()
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let children: [AUParameterNode] = [
            masterVolume,
            pitchBend,
            vibratoDepth,
            vibratoFrequency,
            voiceVibratoDepth,
            voiceVibratoFrequency,
            filterCutoff,
            filterStrength,
            filterResonance,
            glideRate,
            attackDuration,
            holdDuration,
            decayDuration,
            sustainLevel,
            releaseHoldDuration,
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
            filterEnvelopeVelocityScaling
        ]

        parameterTree = AUParameterTree.createTree(withChildren: children)

        masterVolume.value = 1.0
        pitchBend.value = 0.0
        vibratoDepth.value = 0.0
        vibratoFrequency.value = 5.0
        voiceVibratoDepth.value = 0.0
        voiceVibratoFrequency.value = 5.0
        filterCutoff.value = 4.0
        filterStrength.value = 20.0
        filterResonance.value = 0.0
        glideRate.value = 0.0
        attackDuration.value = 0.0
        holdDuration.value = 0.0
        decayDuration.value = 0.0
        sustainLevel.value = 1.0
        releaseHoldDuration.value = 0.0
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
        restartVoiceLFO.value = 0.0
        keyTrackingFraction.value = 1.0
        filterEnvelopeVelocityScaling.value = 0.0
    }

    /// This unit can process in place
    public override var canProcessInPlace: Bool { return true }

    /// Stop all voices
    public func stopAllVoices() {
        akSamplerStopAllVoices(dsp)
    }

    /// Restart voices
    public func restartVoices() {
        akSamplerRestartVoices(dsp)
    }

    /// Load sample data from sample descriptor
    /// - Parameter sampleDataDescriptor: Sample descriptor
    public func loadSampleData(from sampleDataDescriptor: SampleDataDescriptor) {
        var copy = sampleDataDescriptor
        akSamplerLoadData(dsp, &copy)
    }

    /// Load data from compressed file
    /// - Parameter sampleFileDescriptor: Sample descriptor information
    public func loadCompressedSampleFile(from sampleFileDescriptor: SampleFileDescriptor) {
        var copy = sampleFileDescriptor
        akSamplerLoadCompressedFile(dsp, &copy)
    }

    /// Unload all the samples from memory
    public func unloadAllSamples() {
        akSamplerUnloadAllSamples(dsp)
    }

    /// Assign a note number to a particular frequency
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - frequency: Frequency in Hertz
    public func setNoteFrequency(noteNumber: Int32, noteFrequency: Float) {
        akSamplerSetNoteFrequency(dsp, noteNumber, noteFrequency)
    }

    /// Create a simple key map
    public func buildSimpleKeyMap() {
        akSamplerBuildSimpleKeyMap(dsp)
    }

    /// Build key map
    public func buildKeyMap() {
        akSamplerBuildKeyMap(dsp)
    }

    /// Set Loop
    /// - Parameter thruRelease: Wether or not to loop before or after the release
    public func setLoop(thruRelease: Bool) {
        akSamplerSetLoopThruRelease(dsp, thruRelease)
    }

    /// Play the sampler
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: Velocity of the note
    ///   - channel: MIDI Channel
    public func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        akSamplerPlayNote(dsp, noteNumber, velocity)
    }

    /// Stop the sampler playback of a specific note
    /// - Parameter noteNumber: MIDI Note number
    public func stopNote(noteNumber: MIDINoteNumber, immediate: Bool) {
        akSamplerStopNote(dsp, noteNumber, immediate)
    }

    /// Activate the sustain pedal
    /// - Parameter pedalDown: Wether the pedal is down (activated)
    public func sustainPedal(down: Bool) {
        akSamplerSustainPedal(dsp, down)
    }
}
