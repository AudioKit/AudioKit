// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPluckedStringAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPluckedStringDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Variable frequency. Values less than the initial frequency  will be doubled until it is greater than that.",
            address: AKPluckedStringParameter.frequency.rawValue,
            range: AKPluckedString.frequencyRange,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPluckedStringParameter.amplitude.rawValue,
            range: AKPluckedString.amplitudeRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, amplitude])

        frequency.value = AUValue(AKPluckedString.defaultFrequency)
        amplitude.value = AUValue(AKPluckedString.defaultAmplitude)
    }
}
