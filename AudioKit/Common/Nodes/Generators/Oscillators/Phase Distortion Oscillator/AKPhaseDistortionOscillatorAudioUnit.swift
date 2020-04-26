// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPhaseDistortionOscillatorAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var amplitude: AUParameter!

    private(set) var phaseDistortion: AUParameter!

    private(set) var detuningOffset: AUParameter!

    private(set) var detuningMultiplier: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPhaseDistortionOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKPhaseDistortionOscillatorParameter.frequency.rawValue,
            range: AKPhaseDistortionOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPhaseDistortionOscillatorParameter.amplitude.rawValue,
            range: AKPhaseDistortionOscillator.amplitudeRange,
            unit: .generic,
            flags: .default)
        phaseDistortion = AUParameter(
            identifier: "phaseDistortion",
            name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
            address: AKPhaseDistortionOscillatorParameter.phaseDistortion.rawValue,
            range: AKPhaseDistortionOscillator.phaseDistortionRange,
            unit: .generic,
            flags: .default)
        detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKPhaseDistortionOscillatorParameter.detuningOffset.rawValue,
            range: AKPhaseDistortionOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKPhaseDistortionOscillatorParameter.detuningMultiplier.rawValue,
            range: AKPhaseDistortionOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, amplitude, phaseDistortion, detuningOffset, detuningMultiplier])

        frequency.value = AUValue(AKPhaseDistortionOscillator.defaultFrequency)
        amplitude.value = AUValue(AKPhaseDistortionOscillator.defaultAmplitude)
        phaseDistortion.value = AUValue(AKPhaseDistortionOscillator.defaultPhaseDistortion)
        detuningOffset.value = AUValue(AKPhaseDistortionOscillator.defaultDetuningOffset)
        detuningMultiplier.value = AUValue(AKPhaseDistortionOscillator.defaultDetuningMultiplier)
    }
}
