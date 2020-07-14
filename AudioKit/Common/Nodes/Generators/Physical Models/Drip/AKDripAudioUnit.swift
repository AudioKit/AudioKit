// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKDripAudioUnit: AKAudioUnitBase {

    let intensity = AUParameter(
        identifier: "intensity",
        name: "The intensity of the dripping sounds.",
        address: AKDripParameter.intensity.rawValue,
        range: 0 ... 100,
        unit: .generic,
        flags: .default)

    let dampingFactor = AUParameter(
        identifier: "dampingFactor",
        name: "The damping factor. Maximum value is 2.0.",
        address: AKDripParameter.dampingFactor.rawValue,
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    let energyReturn = AUParameter(
        identifier: "energyReturn",
        name: "The amount of energy to add back into the system.",
        address: AKDripParameter.energyReturn.rawValue,
        range: 0 ... 100,
        unit: .generic,
        flags: .default)

    let mainResonantFrequency = AUParameter(
        identifier: "mainResonantFrequency",
        name: "Main resonant frequency.",
        address: AKDripParameter.mainResonantFrequency.rawValue,
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    let firstResonantFrequency = AUParameter(
        identifier: "firstResonantFrequency",
        name: "The first resonant frequency.",
        address: AKDripParameter.firstResonantFrequency.rawValue,
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    let secondResonantFrequency = AUParameter(
        identifier: "secondResonantFrequency",
        name: "The second resonant frequency.",
        address: AKDripParameter.secondResonantFrequency.rawValue,
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude.",
        address: AKDripParameter.amplitude.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createDripDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [intensity,
                                                                  dampingFactor,
                                                                  energyReturn,
                                                                  mainResonantFrequency,
                                                                  firstResonantFrequency,
                                                                  secondResonantFrequency,
                                                                  amplitude])
    }
}
