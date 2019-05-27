//
//  AKPhaseDistortionOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPhaseDistortionOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPhaseDistortionOscillatorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPhaseDistortionOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKPhaseDistortionOscillator.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKPhaseDistortionOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var phaseDistortion: Double = AKPhaseDistortionOscillator.defaultPhaseDistortion {
        didSet { setParameter(.phaseDistortion, value: phaseDistortion) }
    }

    var detuningOffset: Double = AKPhaseDistortionOscillator.defaultDetuningOffset {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }

    var detuningMultiplier: Double = AKPhaseDistortionOscillator.defaultDetuningMultiplier {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPhaseDistortionOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKPhaseDistortionOscillatorParameter.frequency.rawValue,
            range: AKPhaseDistortionOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPhaseDistortionOscillatorParameter.amplitude.rawValue,
            range: AKPhaseDistortionOscillator.amplitudeRange,
            unit: .generic,
            flags: .default)
        let phaseDistortion = AUParameter(
            identifier: "phaseDistortion",
            name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
            address: AKPhaseDistortionOscillatorParameter.phaseDistortion.rawValue,
            range: AKPhaseDistortionOscillator.phaseDistortionRange,
            unit: .generic,
            flags: .default)
        let detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKPhaseDistortionOscillatorParameter.detuningOffset.rawValue,
            range: AKPhaseDistortionOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        let detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKPhaseDistortionOscillatorParameter.detuningMultiplier.rawValue,
            range: AKPhaseDistortionOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, amplitude, phaseDistortion, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKPhaseDistortionOscillator.defaultFrequency)
        amplitude.value = Float(AKPhaseDistortionOscillator.defaultAmplitude)
        phaseDistortion.value = Float(AKPhaseDistortionOscillator.defaultPhaseDistortion)
        detuningOffset.value = Float(AKPhaseDistortionOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKPhaseDistortionOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true }

}
