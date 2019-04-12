//
//  AKDripAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKDripAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKDripParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKDripParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var intensity: Double = AKDrip.defaultIntensity {
        didSet { setParameter(.intensity, value: intensity) }
    }

    var dampingFactor: Double = AKDrip.defaultDampingFactor {
        didSet { setParameter(.dampingFactor, value: dampingFactor) }
    }

    var energyReturn: Double = AKDrip.defaultEnergyReturn {
        didSet { setParameter(.energyReturn, value: energyReturn) }
    }

    var mainResonantFrequency: Double = AKDrip.defaultMainResonantFrequency {
        didSet { setParameter(.mainResonantFrequency, value: mainResonantFrequency) }
    }

    var firstResonantFrequency: Double = AKDrip.defaultFirstResonantFrequency {
        didSet { setParameter(.firstResonantFrequency, value: firstResonantFrequency) }
    }

    var secondResonantFrequency: Double = AKDrip.defaultSecondResonantFrequency {
        didSet { setParameter(.secondResonantFrequency, value: secondResonantFrequency) }
    }

    var amplitude: Double = AKDrip.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createDripDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let intensity = AUParameter(
            identifier: "intensity",
            name: "The intensity of the dripping sounds.",
            address: AKDripParameter.intensity.rawValue,
            range: AKDrip.intensityRange,
            unit: .generic,
            flags: .default)
        let dampingFactor = AUParameter(
            identifier: "dampingFactor",
            name: "The damping factor. Maximum value is 2.0.",
            address: AKDripParameter.dampingFactor.rawValue,
            range: AKDrip.dampingFactorRange,
            unit: .generic,
            flags: .default)
        let energyReturn = AUParameter(
            identifier: "energyReturn",
            name: "The amount of energy to add back into the system.",
            address: AKDripParameter.energyReturn.rawValue,
            range: AKDrip.energyReturnRange,
            unit: .generic,
            flags: .default)
        let mainResonantFrequency = AUParameter(
            identifier: "mainResonantFrequency",
            name: "Main resonant frequency.",
            address: AKDripParameter.mainResonantFrequency.rawValue,
            range: AKDrip.mainResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        let firstResonantFrequency = AUParameter(
            identifier: "firstResonantFrequency",
            name: "The first resonant frequency.",
            address: AKDripParameter.firstResonantFrequency.rawValue,
            range: AKDrip.firstResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        let secondResonantFrequency = AUParameter(
            identifier: "secondResonantFrequency",
            name: "The second resonant frequency.",
            address: AKDripParameter.secondResonantFrequency.rawValue,
            range: AKDrip.secondResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude.",
            address: AKDripParameter.amplitude.rawValue,
            range: AKDrip.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [intensity, dampingFactor, energyReturn, mainResonantFrequency, firstResonantFrequency, secondResonantFrequency, amplitude]))
        intensity.value = Float(AKDrip.defaultIntensity)
        dampingFactor.value = Float(AKDrip.defaultDampingFactor)
        energyReturn.value = Float(AKDrip.defaultEnergyReturn)
        mainResonantFrequency.value = Float(AKDrip.defaultMainResonantFrequency)
        firstResonantFrequency.value = Float(AKDrip.defaultFirstResonantFrequency)
        secondResonantFrequency.value = Float(AKDrip.defaultSecondResonantFrequency)
        amplitude.value = Float(AKDrip.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
