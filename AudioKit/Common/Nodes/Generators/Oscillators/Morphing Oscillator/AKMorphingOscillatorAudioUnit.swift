// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKMorphingOscillatorAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (in Hz)",
        address: AKMorphingOscillatorParameter.frequency.rawValue,
        range: 0.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude (typically a value between 0 and 1).",
        address: AKMorphingOscillatorParameter.amplitude.rawValue,
        range: 0.0 ... 1.0,
        unit: .hertz,
        flags: .default)

    let index = AUParameter(
        identifier: "index",
        name: "Index of the wavetable to use (fractional are okay).",
        address: AKMorphingOscillatorParameter.index.rawValue,
        range: 0.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    let detuningOffset = AUParameter(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKMorphingOscillatorParameter.detuningOffset.rawValue,
        range: -1_000.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    let detuningMultiplier = AUParameter(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKMorphingOscillatorParameter.detuningMultiplier.rawValue,
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createMorphingOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  index,
                                                                  detuningOffset,
                                                                  detuningMultiplier])
    }
}
