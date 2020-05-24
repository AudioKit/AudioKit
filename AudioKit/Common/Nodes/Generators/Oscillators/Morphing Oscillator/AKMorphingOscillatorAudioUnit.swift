// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKMorphingOscillatorAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var amplitude: AUParameter!

    private(set) var index: AUParameter!

    private(set) var detuningOffset: AUParameter!

    private(set) var detuningMultiplier: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createMorphingOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (in Hz)",
            address: AKMorphingOscillatorParameter.frequency.rawValue,
            range: AKMorphingOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude (typically a value between 0 and 1).",
            address: AKMorphingOscillatorParameter.amplitude.rawValue,
            range: AKMorphingOscillator.amplitudeRange,
            unit: .hertz,
            flags: .default)
        index = AUParameter(
            identifier: "index",
            name: "Index of the wavetable to use (fractional are okay).",
            address: AKMorphingOscillatorParameter.index.rawValue,
            range: AKMorphingOscillator.indexRange,
            unit: .hertz,
            flags: .default)
        detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKMorphingOscillatorParameter.detuningOffset.rawValue,
            range: AKMorphingOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKMorphingOscillatorParameter.detuningMultiplier.rawValue,
            range: AKMorphingOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  index,
                                                                  detuningOffset,
                                                                  detuningMultiplier])

        frequency.value = AUValue(AKMorphingOscillator.defaultFrequency)
        amplitude.value = AUValue(AKMorphingOscillator.defaultAmplitude)
        index.value = AUValue(AKMorphingOscillator.defaultIndex)
        detuningOffset.value = AUValue(AKMorphingOscillator.defaultDetuningOffset)
        detuningMultiplier.value = AUValue(AKMorphingOscillator.defaultDetuningMultiplier)
    }
}
