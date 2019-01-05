//
//  AKOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKOscillatorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKOscillator.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var detuningOffset: Double = AKOscillator.defaultDetuningOffset {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }

    var detuningMultiplier: Double = AKOscillator.defaultDetuningMultiplier {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameterTree.createParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKOscillatorParameter.frequency.rawValue,
            range: AKOscillator.frequencyRange,
            
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameterTree.createParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKOscillatorParameter.amplitude.rawValue,
            range: AKOscillator.amplitudeRange,
            
            unit: .generic,
            flags: .default)
        let detuningOffset = AUParameterTree.createParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKOscillatorParameter.detuningOffset.rawValue,
            range: AKOscillator.detuningOffsetRange,
            
            unit: .hertz,
            flags: .default)
        let detuningMultiplier = AUParameterTree.createParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKOscillatorParameter.detuningMultiplier.rawValue,
            range: AKOscillator.detuningMultiplierRange,
            
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, amplitude, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKOscillator.defaultFrequency)
        amplitude.value = Float(AKOscillator.defaultAmplitude)
        detuningOffset.value = Float(AKOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true }

}
