// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKToneComplementFilterAudioUnit: AKAudioUnitBase {

    let halfPowerPoint = AUParameter(
        identifier: "halfPowerPoint",
        name: "Half-Power Point (Hz)",
        address: AKToneComplementFilterParameter.halfPowerPoint.rawValue,
        range: AKToneComplementFilter.halfPowerPointRange,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createToneComplementFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [halfPowerPoint])
    }
}
