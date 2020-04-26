// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFormantFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var attackDuration: AUParameter!

    private(set) var decayDuration: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFormantFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKFormantFilterParameter.centerFrequency.rawValue,
            range: AKFormantFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Impulse response attack time (Seconds)",
            address: AKFormantFilterParameter.attackDuration.rawValue,
            range: AKFormantFilter.attackDurationRange,
            unit: .seconds,
            flags: .default)
        decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Impulse reponse decay time (Seconds)",
            address: AKFormantFilterParameter.decayDuration.rawValue,
            range: AKFormantFilter.decayDurationRange,
            unit: .seconds,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, attackDuration, decayDuration])

        centerFrequency.value = AUValue(AKFormantFilter.defaultCenterFrequency)
        attackDuration.value = AUValue(AKFormantFilter.defaultAttackDuration)
        decayDuration.value = AUValue(AKFormantFilter.defaultDecayDuration)
    }
}
