//
//  AKMorphingOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMorphingOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKMorphingOscillatorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKMorphingOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKMorphingOscillator.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKMorphingOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var index: Double = AKMorphingOscillator.defaultIndex {
        didSet { setParameter(.index, value: index) }
    }

    var detuningOffset: Double = AKMorphingOscillator.defaultDetuningOffset {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }

    var detuningMultiplier: Double = AKMorphingOscillator.defaultDetuningMultiplier {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createMorphingOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (in Hz)",
            address: AKMorphingOscillatorParameter.frequency.rawValue,
            range: AKMorphingOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude (typically a value between 0 and 1).",
            address: AKMorphingOscillatorParameter.amplitude.rawValue,
            range: AKMorphingOscillator.amplitudeRange,
            unit: .hertz,
            flags: .default)
        let index = AUParameter(
            identifier: "index",
            name: "Index of the wavetable to use (fractional are okay).",
            address: AKMorphingOscillatorParameter.index.rawValue,
            range: AKMorphingOscillator.indexRange,
            unit: .hertz,
            flags: .default)
        let detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKMorphingOscillatorParameter.detuningOffset.rawValue,
            range: AKMorphingOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        let detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKMorphingOscillatorParameter.detuningMultiplier.rawValue,
            range: AKMorphingOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, amplitude, index, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKMorphingOscillator.defaultFrequency)
        amplitude.value = Float(AKMorphingOscillator.defaultAmplitude)
        index.value = Float(AKMorphingOscillator.defaultIndex)
        detuningOffset.value = Float(AKMorphingOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKMorphingOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true }

}
