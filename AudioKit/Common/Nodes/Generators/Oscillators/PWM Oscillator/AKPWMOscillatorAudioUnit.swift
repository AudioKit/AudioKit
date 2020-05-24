// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPWMOscillatorAudioUnit: AKAudioUnitBase {

    var frequency: AUParameter!

    var amplitude: AUParameter!

    var pulseWidth: AUParameter!

    var detuningOffset: AUParameter!

    var detuningMultiplier: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPWMOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKPWMOscillatorParameter.frequency.rawValue,
            range: AKPWMOscillator.frequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPWMOscillatorParameter.amplitude.rawValue,
            range: AKPWMOscillator.amplitudeRange,
            unit: .hertz,
            flags: .default)
        pulseWidth = AUParameter(
            identifier: "pulseWidth",
            name: "Pulse Width",
            address: AKPWMOscillatorParameter.pulseWidth.rawValue,
            range: AKPWMOscillator.pulseWidthRange,
            unit: .generic,
            flags: .default)
        detuningOffset = AUParameter(
            identifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AKPWMOscillatorParameter.detuningOffset.rawValue,
            range: AKPWMOscillator.detuningOffsetRange,
            unit: .hertz,
            flags: .default)
        detuningMultiplier = AUParameter(
            identifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AKPWMOscillatorParameter.detuningMultiplier.rawValue,
            range: AKPWMOscillator.detuningMultiplierRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  amplitude,
                                                                  pulseWidth,
                                                                  detuningOffset,
                                                                  detuningMultiplier])

        frequency.value = AUValue(AKPWMOscillator.defaultFrequency)
        amplitude.value = AUValue(AKPWMOscillator.defaultAmplitude)
        pulseWidth.value = AUValue(AKPWMOscillator.defaultPulseWidth)
        detuningOffset.value = AUValue(AKPWMOscillator.defaultDetuningOffset)
        detuningMultiplier.value = AUValue(AKPWMOscillator.defaultDetuningMultiplier)
    }
}
