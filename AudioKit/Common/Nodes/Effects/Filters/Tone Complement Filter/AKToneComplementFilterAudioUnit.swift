// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKToneComplementFilterAudioUnit: AKAudioUnitBase {

    private(set) var halfPowerPoint: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createToneComplementFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        halfPowerPoint = AUParameter(
            identifier: "halfPowerPoint",
            name: "Half-Power Point (Hz)",
            address: AKToneComplementFilterParameter.halfPowerPoint.rawValue,
            range: AKToneComplementFilter.halfPowerPointRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [halfPowerPoint])

        halfPowerPoint.value = AUValue(AKToneComplementFilter.defaultHalfPowerPoint)
    }
}
