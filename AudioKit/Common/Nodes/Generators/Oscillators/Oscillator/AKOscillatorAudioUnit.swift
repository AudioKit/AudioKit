// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKOscillatorAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKOscillatorParameter.frequency.rawValue,
        range: AKOscillator.frequencyRange,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKOscillatorParameter.amplitude.rawValue,
        range: AKOscillator.amplitudeRange,
        unit: .generic,
        flags: .default)

    let detuningOffset = AUParameter(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKOscillatorParameter.detuningOffset.rawValue,
        range: AKOscillator.detuningOffsetRange,
        unit: .hertz,
        flags: .default)

    let detuningMultiplier = AUParameter(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKOscillatorParameter.detuningMultiplier.rawValue,
        range: AKOscillator.detuningMultiplierRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  detuningOffset,
                                                                  detuningMultiplier])
    }
}
