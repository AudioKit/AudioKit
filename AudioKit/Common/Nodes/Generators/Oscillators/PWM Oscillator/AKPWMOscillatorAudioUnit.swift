//
//  AKPWMOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPWMOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPWMOscillatorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPWMOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKPWMOscillator.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKPWMOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var pulseWidth: Double = AKPWMOscillator.defaultPulseWidth {
        didSet { setParameter(.pulseWidth, value: pulseWidth) }
    }

    var detuningOffset: Double = AKPWMOscillator.defaultDetuningOffset {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }

    var detuningMultiplier: Double = AKPWMOscillator.defaultDetuningMultiplier {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPWMOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKPWMOscillatorParameter.frequency.rawValue,
            range: AKPWMOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPWMOscillatorParameter.amplitude.rawValue,
            range: AKPWMOscillator.amplitudeRange,
            unit: .hertz,
            flags: .default)
        let pulseWidth = AUParameter(
            identifier: "pulseWidth",
            name: "Pulse Width",
            address: AKPWMOscillatorParameter.pulseWidth.rawValue,
            range: AKPWMOscillator.pulseWidthRange,
            unit: .generic,
            flags: .default)
        let detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKPWMOscillatorParameter.detuningOffset.rawValue,
            range: AKPWMOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        let detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKPWMOscillatorParameter.detuningMultiplier.rawValue,
            range: AKPWMOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, amplitude, pulseWidth, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKPWMOscillator.defaultFrequency)
        amplitude.value = Float(AKPWMOscillator.defaultAmplitude)
        pulseWidth.value = Float(AKPWMOscillator.defaultPulseWidth)
        detuningOffset.value = Float(AKPWMOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKPWMOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true }

}
