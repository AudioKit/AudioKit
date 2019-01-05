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

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Frequency (Hz)",
            address: AKPWMOscillatorParameter.frequency.rawValue,
            min: Float(AKPWMOscillator.frequencyRange.lowerBound),
            max: Float(AKPWMOscillator.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AKPWMOscillatorParameter.amplitude.rawValue,
            min: Float(AKPWMOscillator.amplitudeRange.lowerBound),
            max: Float(AKPWMOscillator.amplitudeRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )
        let pulseWidth = AUParameterTree.createParameter(
            withIdentifier: "pulseWidth",
            name: "Pulse Width",
            address: AKPWMOscillatorParameter.pulseWidth.rawValue,
            min: Float(AKPWMOscillator.pulseWidthRange.lowerBound),
            max: Float(AKPWMOscillator.pulseWidthRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningOffset = AUParameterTree.createParameter(
            withIdentifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKPWMOscillatorParameter.detuningOffset.rawValue,
            min: Float(AKPWMOscillator.detuningOffsetRange.lowerBound),
            max: Float(AKPWMOscillator.detuningOffsetRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningMultiplier = AUParameterTree.createParameter(
            withIdentifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKPWMOscillatorParameter.detuningMultiplier.rawValue,
            min: Float(AKPWMOscillator.detuningMultiplierRange.lowerBound),
            max: Float(AKPWMOscillator.detuningMultiplierRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, amplitude, pulseWidth, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKPWMOscillator.defaultFrequency)
        amplitude.value = Float(AKPWMOscillator.defaultAmplitude)
        pulseWidth.value = Float(AKPWMOscillator.defaultPulseWidth)
        detuningOffset.value = Float(AKPWMOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKPWMOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true }

}
