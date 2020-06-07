// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPhaseDistortionOscillatorAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKPhaseDistortionOscillatorParameter.frequency.rawValue,
        range: AKPhaseDistortionOscillator.frequencyRange,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKPhaseDistortionOscillatorParameter.amplitude.rawValue,
        range: AKPhaseDistortionOscillator.amplitudeRange,
        unit: .generic,
        flags: .default)

    let phaseDistortion = AUParameter(
        identifier: "phaseDistortion",
        name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
        address: AKPhaseDistortionOscillatorParameter.phaseDistortion.rawValue,
        range: AKPhaseDistortionOscillator.phaseDistortionRange,
        unit: .generic,
        flags: .default)

    let detuningOffset = AUParameter(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKPhaseDistortionOscillatorParameter.detuningOffset.rawValue,
        range: AKPhaseDistortionOscillator.detuningOffsetRange,
        unit: .hertz,
        flags: .default)

    let detuningMultiplier = AUParameter(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKPhaseDistortionOscillatorParameter.detuningMultiplier.rawValue,
        range: AKPhaseDistortionOscillator.detuningMultiplierRange,
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
