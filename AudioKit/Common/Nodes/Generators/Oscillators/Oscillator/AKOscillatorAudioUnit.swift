// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKOscillatorAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var amplitude: AUParameter!

    private(set) var detuningOffset: AUParameter!

    private(set) var detuningMultiplier: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKOscillatorParameter.frequency.rawValue,
            range: AKOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKOscillatorParameter.amplitude.rawValue,
            range: AKOscillator.amplitudeRange,
            unit: .generic,
            flags: .default)
        detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKOscillatorParameter.detuningOffset.rawValue,
            range: AKOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKOscillatorParameter.detuningMultiplier.rawValue,
            range: AKOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, amplitude, detuningOffset, detuningMultiplier])

        frequency.value = AUValue(AKOscillator.defaultFrequency)
        amplitude.value = AUValue(AKOscillator.defaultAmplitude)
        detuningOffset.value = AUValue(AKOscillator.defaultDetuningOffset)
        detuningMultiplier.value = AUValue(AKOscillator.defaultDetuningMultiplier)
    }
}
