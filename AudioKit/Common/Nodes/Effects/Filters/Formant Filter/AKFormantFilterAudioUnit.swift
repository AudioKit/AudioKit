// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFormantFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKFormantFilterParameter.centerFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let attackDuration = AUParameter(
        identifier: "attackDuration",
        name: "Impulse response attack time (Seconds)",
        address: AKFormantFilterParameter.attackDuration.rawValue,
        range: 0.0 ... 0.1,
        unit: .seconds,
        flags: .default)

    let decayDuration = AUParameter(
        identifier: "decayDuration",
        name: "Impulse reponse decay time (Seconds)",
        address: AKFormantFilterParameter.decayDuration.rawValue,
        range: 0.0 ... 0.1,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createFormantFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, attackDuration, decayDuration])
    }
}
