//
//  AKDripAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKDripAudioUnit: AKAudioUnitBase {

    private(set) var intensity: AUParameter!

    private(set) var dampingFactor: AUParameter!

    private(set) var energyReturn: AUParameter!

    private(set) var mainResonantFrequency: AUParameter!

    private(set) var firstResonantFrequency: AUParameter!

    private(set) var secondResonantFrequency: AUParameter!

    private(set) var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createDripDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        intensity = AUParameter(
            identifier: "intensity",
            name: "The intensity of the dripping sounds.",
            address: AKDripParameter.intensity.rawValue,
            range: AKDrip.intensityRange,
            unit: .generic,
            flags: .default)
        dampingFactor = AUParameter(
            identifier: "dampingFactor",
            name: "The damping factor. Maximum value is 2.0.",
            address: AKDripParameter.dampingFactor.rawValue,
            range: AKDrip.dampingFactorRange,
            unit: .generic,
            flags: .default)
        energyReturn = AUParameter(
            identifier: "energyReturn",
            name: "The amount of energy to add back into the system.",
            address: AKDripParameter.energyReturn.rawValue,
            range: AKDrip.energyReturnRange,
            unit: .generic,
            flags: .default)
        mainResonantFrequency = AUParameter(
            identifier: "mainResonantFrequency",
            name: "Main resonant frequency.",
            address: AKDripParameter.mainResonantFrequency.rawValue,
            range: AKDrip.mainResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        firstResonantFrequency = AUParameter(
            identifier: "firstResonantFrequency",
            name: "The first resonant frequency.",
            address: AKDripParameter.firstResonantFrequency.rawValue,
            range: AKDrip.firstResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        secondResonantFrequency = AUParameter(
            identifier: "secondResonantFrequency",
            name: "The second resonant frequency.",
            address: AKDripParameter.secondResonantFrequency.rawValue,
            range: AKDrip.secondResonantFrequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude.",
            address: AKDripParameter.amplitude.rawValue,
            range: AKDrip.amplitudeRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [intensity, dampingFactor, energyReturn, mainResonantFrequency, firstResonantFrequency, secondResonantFrequency, amplitude])

        intensity.value = AUValue(AKDrip.defaultIntensity)
        dampingFactor.value = AUValue(AKDrip.defaultDampingFactor)
        energyReturn.value = AUValue(AKDrip.defaultEnergyReturn)
        mainResonantFrequency.value = AUValue(AKDrip.defaultMainResonantFrequency)
        firstResonantFrequency.value = AUValue(AKDrip.defaultFirstResonantFrequency)
        secondResonantFrequency.value = AUValue(AKDrip.defaultSecondResonantFrequency)
        amplitude.value = AUValue(AKDrip.defaultAmplitude)
    }
}
