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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKDripParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createDripDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let intensity = AUParameterTree.createParameter(
            withIdentifier: "intensity",
            name: "The intensity of the dripping sounds.",
            address: AUParameterAddress(0),
            min: Float(AKDrip.intensityRange.lowerBound),
            max: Float(AKDrip.intensityRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let dampingFactor = AUParameterTree.createParameter(
            withIdentifier: "dampingFactor",
            name: "The damping factor. Maximum value is 2.0.",
            address: AUParameterAddress(1),
            min: Float(AKDrip.dampingFactorRange.lowerBound),
            max: Float(AKDrip.dampingFactorRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let energyReturn = AUParameterTree.createParameter(
            withIdentifier: "energyReturn",
            name: "The amount of energy to add back into the system.",
            address: AUParameterAddress(2),
            min: Float(AKDrip.energyReturnRange.lowerBound),
            max: Float(AKDrip.energyReturnRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let mainResonantFrequency = AUParameterTree.createParameter(
            withIdentifier: "mainResonantFrequency",
            name: "Main resonant frequency.",
            address: AUParameterAddress(3),
            min: Float(AKDrip.mainResonantFrequencyRange.lowerBound),
            max: Float(AKDrip.mainResonantFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let firstResonantFrequency = AUParameterTree.createParameter(
            withIdentifier: "firstResonantFrequency",
            name: "The first resonant frequency.",
            address: AUParameterAddress(4),
            min: Float(AKDrip.firstResonantFrequencyRange.lowerBound),
            max: Float(AKDrip.firstResonantFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let secondResonantFrequency = AUParameterTree.createParameter(
            withIdentifier: "secondResonantFrequency",
            name: "The second resonant frequency.",
            address: AUParameterAddress(5),
            min: Float(AKDrip.secondResonantFrequencyRange.lowerBound),
            max: Float(AKDrip.secondResonantFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude.",
            address: AUParameterAddress(6),
            min: Float(AKDrip.amplitudeRange.lowerBound),
            max: Float(AKDrip.amplitudeRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [intensity, dampingFactor, energyReturn, mainResonantFrequency, firstResonantFrequency, secondResonantFrequency, amplitude]))
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
