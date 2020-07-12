// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPhaseDistortionOscillatorAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKPhaseDistortionOscillatorParameter.frequency.rawValue,
        range: 0 ... 20_000,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKPhaseDistortionOscillatorParameter.amplitude.rawValue,
        range: 0 ... 10,
        unit: .generic,
        flags: .default)

    let phaseDistortion = AUParameter(
        identifier: "phaseDistortion",
        name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
        address: AKPhaseDistortionOscillatorParameter.phaseDistortion.rawValue,
        range: -1 ... 1,
        unit: .generic,
        flags: .default)

    let detuningOffset = AUParameter(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKPhaseDistortionOscillatorParameter.detuningOffset.rawValue,
        range: -1_000 ... 1_000,
        unit: .hertz,
        flags: .default)

    let detuningMultiplier = AUParameter(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKPhaseDistortionOscillatorParameter.detuningMultiplier.rawValue,
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPhaseDistortionOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  phaseDistortion,
                                                                  detuningOffset,
                                                                  detuningMultiplier])
    }
}
