// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKAutoWahAudioUnit: AKAudioUnitBase {

    let wah = AUParameter(
        identifier: "wah",
        name: "Wah Amount",
        address: AKAutoWahParameter.wah.rawValue,
        range: AKAutoWah.wahRange,
        unit: .generic,
        flags: .default)

    let mix = AUParameter(
        identifier: "mix",
        name: "Dry/Wet Mix",
        address: AKAutoWahParameter.mix.rawValue,
        range: AKAutoWah.mixRange,
        unit: .percent,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Overall level",
        address: AKAutoWahParameter.amplitude.rawValue,
        range: AKAutoWah.amplitudeRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createAutoWahDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [wah, mix, amplitude])
    }
}
