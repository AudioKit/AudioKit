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
    
    var loopThruRelease: Double = 0.0 {
        didSet { setParameter(.loopThruRelease, value: loopThruRelease) }
    }
    
    var isMonophonic: Double = 0.0 {
        didSet { setParameter(.monophonic, value: isMonophonic) }
    }
    
    var isLegato: Double = 0.0 {
        didSet { setParameter(.legato, value: isLegato) }
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
        
        var parameterAddress = 0
        let masterVolumeParameter = AUParameterTree.createParameter(
            withIdentifier: "masterVolume",
            name: "Master Volume",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .generic, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let pitchBendParameter = AUParameterTree.createParameter(
            withIdentifier: "pitchBend",
            name: "Pitch Offset (semitones)",
            address: AUParameterAddress(parameterAddress),
            min: -1_000.0, max: 1_000.0,
            unit: .relativeSemiTones, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let vibratoDepthParameter = AUParameterTree.createParameter(
            withIdentifier: "vibratoDepth",
            name: "Vibrato amount (semitones)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 24.0,
            unit: .relativeSemiTones, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterCutoffParameter = AUParameterTree.createParameter(
            withIdentifier: "filterCutoff",
            name: "Filter cutoff (harmonic))",
            address: AUParameterAddress(parameterAddress),
            min: 1.0, max: 1_000.0,
            unit: .ratio, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterStrengthParameter = AUParameterTree.createParameter(
            withIdentifier: "filterStrength",
            name: "Filter EG strength",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .ratio, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterResonanceParameter = AUParameterTree.createParameter(
            withIdentifier: "filterResonance",
            name: "Filter resonance (dB))",
            address: AUParameterAddress(parameterAddress),
            min: -20.0, max: 20.0,
            unit: .decibels, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)
        
        parameterAddress += 1

        let glideRateParameter = AUParameterTree.createParameter(
            withIdentifier: "glideRate",
            name: "Glide rate (sec/octave))",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 10.0,
            unit: .seconds, unitName: nil,
            flags: rampFlags,
            valueStrings: nil, dependentParameters: nil)
        
        parameterAddress += 1

        let attackDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "attackDuration",
            name: "Amplitude Attack duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let decayDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "decayDuration",
            name: "Amplitude Decay duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let sustainLevelParameter = AUParameterTree.createParameter(
            withIdentifier: "sustainLevel",
            name: "Amplitude Sustain level (fraction)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .generic, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let releaseDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "releaseDuration",
            name: "Amplitude Release duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterAttackDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "filterAttackDuration",
            name: "Filter Attack duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterDecayDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "filterDecayDuration",
            name: "Filter Decay duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterSustainLevelParameter = AUParameterTree.createParameter(
            withIdentifier: "filterSustainLevel",
            name: "Filter Sustain level (fraction)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .generic, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterReleaseDurationParameter = AUParameterTree.createParameter(
            withIdentifier: "filterReleaseDuration",
            name: "Filter Release duration (seconds)",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1_000.0,
            unit: .seconds, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let filterEnableParameter = AUParameterTree.createParameter(
            withIdentifier: "filterEnable",
            name: "Filter Enable",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .boolean, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let loopThruReleaseParameter = AUParameterTree.createParameter(
            withIdentifier: "loopThruRelease",
            name: "Loop Thru Release",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .boolean, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let monophonicParameter = AUParameterTree.createParameter(
            withIdentifier: "monophonic",
            name: "Monophonic Mode",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .boolean, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)

        parameterAddress += 1

        let legatoParameter = AUParameterTree.createParameter(
            withIdentifier: "legato",
            name: "Legato Mode",
            address: AUParameterAddress(parameterAddress),
            min: 0.0, max: 1.0,
            unit: .boolean, unitName: nil,
            flags: nonRampFlags,
            valueStrings: nil, dependentParameters: nil)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [masterVolumeParameter,
                                                                   pitchBendParameter,
                                                                   vibratoDepthParameter,
                                                                   filterCutoffParameter,
                                                                   filterStrengthParameter,
                                                                   filterResonanceParameter,
                                                                   glideRateParameter,
                                                                   attackDurationParameter,
                                                                   decayDurationParameter,
                                                                   sustainLevelParameter,
                                                                   releaseDurationParameter,
                                                                   filterAttackDurationParameter,
                                                                   filterDecayDurationParameter,
                                                                   filterSustainLevelParameter,
                                                                   filterReleaseDurationParameter,
                                                                   filterEnableParameter,
                                                                   loopThruReleaseParameter,
                                                                   monophonicParameter,
                                                                   legatoParameter]))
        masterVolumeParameter.value = 1.0
        pitchBendParameter.value = 0.0
        vibratoDepthParameter.value = 0.0
        filterCutoffParameter.value = 4.0
        filterStrengthParameter.value = 20.0
        filterResonanceParameter.value = 0.0
        glideRateParameter.value = 0.0
        attackDurationParameter.value = 0.0
        decayDurationParameter.value = 0.0
        sustainLevelParameter.value = 1.0
        releaseDurationParameter.value = 0.0
        filterAttackDurationParameter.value = 0.0
        filterDecayDurationParameter.value = 0.0
        filterSustainLevelParameter.value = 1.0
        filterReleaseDurationParameter.value = 0.0
        filterEnableParameter.value = 0.0
        loopThruReleaseParameter.value = 0.0
        monophonicParameter.value = 0.0
        legatoParameter.value = 0.0
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
    
    public func playNote(noteNumber: UInt8,
                         velocity: UInt8,
                         noteFrequency: Float) {
        doAKSamplerPlayNote(pDSP, noteNumber, velocity, noteFrequency)
    }
    
    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAKSamplerStopNote(pDSP, noteNumber, immediate)
    }
    
    public func sustainPedal(down: Bool) {
        doAKSamplerSustainPedal(pDSP, down)
    }

}
