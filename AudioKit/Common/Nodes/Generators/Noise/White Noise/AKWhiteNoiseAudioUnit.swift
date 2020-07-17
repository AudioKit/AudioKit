// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKWhiteNoiseAudioUnit: AKAudioUnitBase {

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKWhiteNoiseParameter.amplitude.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createWhiteNoiseDSP()
    }
}
