// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFMOscillatorAudioUnit: AKAudioUnitBase {

    let baseFrequency = AUParameter(
        identifier: "baseFrequency",
        name: "Base Frequency (Hz)",
        address: AKFMOscillatorParameter.baseFrequency.rawValue,
        range: AKFMOscillator.baseFrequencyRange,
        unit: .hertz,
        flags: .default)

    let carrierMultiplier = AUParameter(
        identifier: "carrierMultiplier",
        name: "Carrier Multiplier",
        address: AKFMOscillatorParameter.carrierMultiplier.rawValue,
        range: AKFMOscillator.carrierMultiplierRange,
        unit: .generic,
        flags: .default)

    let modulatingMultiplier = AUParameter(
        identifier: "modulatingMultiplier",
        name: "Modulating Multiplier",
        address: AKFMOscillatorParameter.modulatingMultiplier.rawValue,
        range: AKFMOscillator.modulatingMultiplierRange,
        unit: .generic,
        flags: .default)

    let modulationIndex = AUParameter(
        identifier: "modulationIndex",
        name: "Modulation Index",
        address: AKFMOscillatorParameter.modulationIndex.rawValue,
        range: AKFMOscillator.modulationIndexRange,
        unit: .generic,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKFMOscillatorParameter.amplitude.rawValue,
        range: AKFMOscillator.amplitudeRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createFMOscillatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [baseFrequency,
                                                                  carrierMultiplier,
                                                                  modulatingMultiplier,
                                                                  modulationIndex,
                                                                  amplitude])
    }
}
