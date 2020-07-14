// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKPhaseLockedVocoderAudioUnit: AKAudioUnitBase {

    let position = AUParameter(
        identifier: "position",
        name: "Position in time. When non-changing it will do a spectral freeze of a the current point in time.",
        address: AKPhaseLockedVocoderParameter.position.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude.",
        address: AKPhaseLockedVocoderParameter.amplitude.rawValue,
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    let pitchRatio = AUParameter(
        identifier: "pitchRatio",
        name: "Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc.",
        address: AKPhaseLockedVocoderParameter.pitchRatio.rawValue,
        range: 0 ... 1_000,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPhaseLockedVocoderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [position, amplitude, pitchRatio])
    }
}
