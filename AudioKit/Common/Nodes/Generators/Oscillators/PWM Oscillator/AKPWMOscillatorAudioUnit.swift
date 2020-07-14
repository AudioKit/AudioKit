// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKPWMOscillatorAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKPWMOscillatorParameter.frequency.rawValue,
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKPWMOscillatorParameter.amplitude.rawValue,
        range: 0.0 ... 10.0,
        unit: .hertz,
        flags: .default)

    let pulseWidth = AUParameter(
        identifier: "pulseWidth",
        name: "Pulse Width",
        address: AKPWMOscillatorParameter.pulseWidth.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    let detuningOffset = AUParameter(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKPWMOscillatorParameter.detuningOffset.rawValue,
        range: -1_000.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    let detuningMultiplier = AUParameter(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKPWMOscillatorParameter.detuningMultiplier.rawValue,
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPWMOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  pulseWidth,
                                                                  detuningOffset,
                                                                  detuningMultiplier])
    }
}
