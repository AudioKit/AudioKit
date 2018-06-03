//
//  AKSamplerAudioUnit.swift
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKSamplerAudioUnit: AKGeneratorAudioUnitBase {

    var pDSP: UnsafeMutableRawPointer?

    func setParameter(_ address: AKSamplerParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKSamplerParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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

    var filterEgStrength: Double = 20.0 {
        didSet { setParameter(.filterEgStrength, value: filterCutoff) }
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

    var filterEnable: Double = 0.0 {
        didSet { setParameter(.filterEnable, value: filterEnable) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        pDSP = createAKSamplerDSP(Int32(count), sampleRate)
        return pDSP
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let rampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        var paramAddress = 0
        let masterVolumeParam = AUParameterTree.createParameter(withIdentifier: "masterVolume",
                                                                name: "Master Volume",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1.0,
                                                                unit: .generic, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let pitchBendParam = AUParameterTree.createParameter(withIdentifier: "pitchBend",
                                                             name: "Pitch Offset (semitones)",
                                                             address: AUParameterAddress(paramAddress),
                                                             min: -1_000.0, max: 1_000.0,
                                                             unit: .relativeSemiTones, unitName: nil,
                                                             flags: rampFlags,
                                                             valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let vibratoDepthParam = AUParameterTree.createParameter(withIdentifier: "vibratoDepth",
                                                                name: "Vibrato amount (semitones)",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 24.0,
                                                                unit: .relativeSemiTones, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterCutoffParam = AUParameterTree.createParameter(withIdentifier: "filterCutoff",
                                                                name: "Filter cutoff (harmonic))",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 1.0, max: 1_000.0,
                                                                unit: .ratio, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterEgStrengthParam = AUParameterTree.createParameter(withIdentifier: "filterEgStrength",
                                                                    name: "Filter EG strength",
                                                                    address: AUParameterAddress(paramAddress),
                                                                    min: 0.0, max: 1_000.0,
                                                                    unit: .ratio, unitName: nil,
                                                                    flags: rampFlags,
                                                                    valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterResonanceParam = AUParameterTree.createParameter(withIdentifier: "filterResonance",
                                                                   name: "Filter resonance (dB))",
                                                                   address: AUParameterAddress(paramAddress),
                                                                   min: -20.0, max: 20.0,
                                                                   unit: .decibels, unitName: nil,
                                                                   flags: rampFlags,
                                                                   valueStrings: nil, dependentParameters: nil)

        paramAddress += 1
        let attackDurationParam = AUParameterTree.createParameter(withIdentifier: "attackDuration",
                                                                  name: "Amplitude Attack duration (seconds)",
                                                                  address: AUParameterAddress(paramAddress),
                                                                  min: 0.0, max: 1_000.0,
                                                                  unit: .seconds, unitName: nil,
                                                                  flags: nonRampFlags,
                                                                  valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let decayDurationParam = AUParameterTree.createParameter(withIdentifier: "decayDuration",
                                                                 name: "Amplitude Decay duration (seconds)",
                                                                 address: AUParameterAddress(paramAddress),
                                                                 min: 0.0, max: 1_000.0,
                                                                 unit: .seconds, unitName: nil,
                                                                 flags: nonRampFlags,
                                                                 valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let sustainLevelParam = AUParameterTree.createParameter(withIdentifier: "sustainLevel",
                                                                name: "Amplitude Sustain level (fraction)",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1.0,
                                                                unit: .generic, unitName: nil,
                                                                flags: nonRampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let releaseDurationParam = AUParameterTree.createParameter(withIdentifier: "releaseDuration",
                                                                   name: "Amplitude Release duration (seconds)",
                                                                   address: AUParameterAddress(paramAddress),
                                                                   min: 0.0, max: 1_000.0,
                                                                   unit: .seconds, unitName: nil,
                                                                   flags: nonRampFlags,
                                                                   valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterAttackDurationParam = AUParameterTree.createParameter(withIdentifier: "filterAttackDuration",
                                                                    name: "Filter Attack duration (seconds)",
                                                                    address: AUParameterAddress(paramAddress),
                                                                    min: 0.0, max: 1_000.0,
                                                                    unit: .seconds, unitName: nil,
                                                                    flags: nonRampFlags,
                                                                    valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterDecayDurationParam = AUParameterTree.createParameter(withIdentifier: "filterDecayDuration",
                                                                   name: "Filter Decay duration (seconds)",
                                                                   address: AUParameterAddress(paramAddress),
                                                                   min: 0.0, max: 1_000.0,
                                                                   unit: .seconds, unitName: nil,
                                                                   flags: nonRampFlags,
                                                                   valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterSustainLevelParam = AUParameterTree.createParameter(withIdentifier: "filterSustainLevel",
                                                                      name: "Filter Sustain level (fraction)",
                                                                      address: AUParameterAddress(paramAddress),
                                                                      min: 0.0, max: 1.0,
                                                                      unit: .generic, unitName: nil,
                                                                      flags: nonRampFlags,
                                                                      valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterReleaseDurationParam = AUParameterTree.createParameter(withIdentifier: "filterReleaseDuration",
                                                                     name: "Filter Release duration (seconds)",
                                                                     address: AUParameterAddress(paramAddress),
                                                                     min: 0.0, max: 1_000.0,
                                                                     unit: .seconds, unitName: nil,
                                                                     flags: nonRampFlags,
                                                                     valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterEnableParam = AUParameterTree.createParameter(withIdentifier: "filterEnable",
                                                                name: "Filter Enable",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1.0,
                                                                unit: .boolean, unitName: nil,
                                                                flags: nonRampFlags,
                                                                valueStrings: nil, dependentParameters: nil)

        setParameterTree(AUParameterTree.createTree(withChildren: [masterVolumeParam, pitchBendParam, vibratoDepthParam,
                                                                   filterCutoffParam, filterEgStrengthParam, filterResonanceParam,
                                                                   attackDurationParam, decayDurationParam,
                                                                   sustainLevelParam, releaseDurationParam,
                                                                   filterAttackDurationParam, filterDecayDurationParam,
                                                                   filterSustainLevelParam, filterReleaseDurationParam,
                                                                   filterEnableParam ]))
        masterVolumeParam.value = 1.0
        pitchBendParam.value = 0.0
        vibratoDepthParam.value = 0.0
        filterCutoffParam.value = 4.0
        filterEgStrengthParam.value = 20.0
        filterResonanceParam.value = 0.0
        attackDurationParam.value = 0.0
        decayDurationParam.value = 0.0
        sustainLevelParam.value = 1.0
        releaseDurationParam.value = 0.0
        filterAttackDurationParam.value = 0.0
        filterDecayDurationParam.value = 0.0
        filterSustainLevelParam.value = 1.0
        filterReleaseDurationParam.value = 0.0
        filterEnableParam.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true }

    public func stopAllVoices() {
        doAKSamplerStopAllVoices(pDSP)
    }

    public func restartVoices() {
        doAKSamplerRestartVoices(pDSP)
    }

    public func loadSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        var copy = sampleDataDescriptor
        doAKSamplerLoadData(pDSP, &copy)
    }

    public func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        var copy = sampleFileDescriptor
        doAKSamplerLoadCompressedFile(pDSP, &copy)
    }

    public func unloadAllSamples() {
        doAKSamplerUnloadAllSamples(pDSP)
    }

    public func buildSimpleKeyMap() {
        doAKSamplerBuildSimpleKeyMap(pDSP)
    }

    public func buildKeyMap() {
        doAKSamplerBuildKeyMap(pDSP)
    }

    public func setLoop(thruRelease: Bool) {
        doAKSamplerSetLoopThruRelease(pDSP, thruRelease)
    }

    public func playNote(noteNumber: UInt8, velocity: UInt8, noteFrequency: Float) {
        doAKSamplerPlayNote(pDSP, noteNumber, velocity, noteFrequency)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAKSamplerStopNote(pDSP, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        doAKSamplerSustainPedal(pDSP, down)
    }

}
