// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKPluckedStringAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Variable frequency. Values less than the initial frequency will be doubled until greater than that.",
        address: AKPluckedStringParameter.frequency.rawValue,
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKPluckedStringParameter.amplitude.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPluckedStringDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, amplitude])
    }
}
