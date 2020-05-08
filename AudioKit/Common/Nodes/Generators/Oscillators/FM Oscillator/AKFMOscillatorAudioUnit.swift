// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFMOscillatorAudioUnit: AKAudioUnitBase {

    private(set) var baseFrequency: AUParameter!

    private(set) var carrierMultiplier: AUParameter!

    private(set) var modulatingMultiplier: AUParameter!

    private(set) var modulationIndex: AUParameter!

    private(set) var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFMOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        baseFrequency = AUParameter(
            identifier: "baseFrequency",
            name: "Base Frequency (Hz)",
            address: AKFMOscillatorParameter.baseFrequency.rawValue,
            range: AKFMOscillator.baseFrequencyRange,
            unit: .hertz,
            flags: .default)
        carrierMultiplier = AUParameter(
            identifier: "carrierMultiplier",
            name: "Carrier Multiplier",
            address: AKFMOscillatorParameter.carrierMultiplier.rawValue,
            range: AKFMOscillator.carrierMultiplierRange,
            unit: .generic,
            flags: .default)
        modulatingMultiplier = AUParameter(
            identifier: "modulatingMultiplier",
            name: "Modulating Multiplier",
            address: AKFMOscillatorParameter.modulatingMultiplier.rawValue,
            range: AKFMOscillator.modulatingMultiplierRange,
            unit: .generic,
            flags: .default)
        modulationIndex = AUParameter(
            identifier: "modulationIndex",
            name: "Modulation Index",
            address: AKFMOscillatorParameter.modulationIndex.rawValue,
            range: AKFMOscillator.modulationIndexRange,
            unit: .generic,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKFMOscillatorParameter.amplitude.rawValue,
            range: AKFMOscillator.amplitudeRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [baseFrequency,
                                                                  carrierMultiplier,
                                                                  modulatingMultiplier,
                                                                  modulationIndex,
                                                                  amplitude])

        baseFrequency.value = AUValue(AKFMOscillator.defaultBaseFrequency)
        carrierMultiplier.value = AUValue(AKFMOscillator.defaultCarrierMultiplier)
        modulatingMultiplier.value = AUValue(AKFMOscillator.defaultModulatingMultiplier)
        modulationIndex.value = AUValue(AKFMOscillator.defaultModulationIndex)
        amplitude.value = AUValue(AKFMOscillator.defaultAmplitude)
    }
}
