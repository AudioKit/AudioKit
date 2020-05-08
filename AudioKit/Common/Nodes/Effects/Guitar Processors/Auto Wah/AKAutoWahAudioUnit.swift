// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKAutoWahAudioUnit: AKAudioUnitBase {

    private(set) var wah: AUParameter!

    private(set) var mix: AUParameter!

    private(set) var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createAutoWahDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        wah = AUParameter(
            identifier: "wah",
            name: "Wah Amount",
            address: AKAutoWahParameter.wah.rawValue,
            range: AKAutoWah.wahRange,
            unit: .generic,
            flags: .default)
        mix = AUParameter(
            identifier: "mix",
            name: "Dry/Wet Mix",
            address: AKAutoWahParameter.mix.rawValue,
            range: AKAutoWah.mixRange,
            unit: .percent,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Overall level",
            address: AKAutoWahParameter.amplitude.rawValue,
            range: AKAutoWah.amplitudeRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [wah, mix, amplitude])

        wah.value = AUValue(AKAutoWah.defaultWah)
        mix.value = AUValue(AKAutoWah.defaultMix)
        amplitude.value = AUValue(AKAutoWah.defaultAmplitude)
    }
}
