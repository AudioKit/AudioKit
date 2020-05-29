// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPitchShifterAudioUnit: AKAudioUnitBase {

    let shift = AUParameter(
        identifier: "shift",
        name: "Pitch shift (in semitones)",
        address: AKPitchShifterParameter.shift.rawValue,
        range: AKPitchShifter.shiftRange,
        unit: .relativeSemiTones,
        flags: .default)

    let windowSize = AUParameter(
        identifier: "windowSize",
        name: "Window size (in samples)",
        address: AKPitchShifterParameter.windowSize.rawValue,
        range: AKPitchShifter.windowSizeRange,
        unit: .hertz,
        flags: .default)

    let crossfade = AUParameter(
        identifier: "crossfade",
        name: "Crossfade (in samples)",
        address: AKPitchShifterParameter.crossfade.rawValue,
        range: AKPitchShifter.crossfadeRange,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPitchShifterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [shift, windowSize, crossfade])
    }
}
