// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBoosterAudioUnit: AKAudioUnitBase {

    var leftGain: AUParameter!

    var rightGain: AUParameter!

    var rampType: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createBoosterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        leftGain = AUParameter(
            identifier: "leftGain",
            name: "Left Boosting Amount",
            address: 0,
            range: 0.0...2.0,
            unit: .linearGain,
            flags: .default)

        rightGain = AUParameter(
            identifier: "rightGain",
            name: "Right Boosting Amount",
            address: 1,
            range: 0.0...2.0,
            unit: .linearGain,
            flags: .default)

        rampType = AUParameter(
            identifier: "rampType",
            name: "Ramp Type",
            address: 2,
            range: 0.0...3.0,
            unit: .indexed,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [leftGain, rightGain, rampType])

        leftGain.value = 1.0
        rightGain.value = 1.0
        rampType.value = AUValue(AKSettings.RampType.linear.rawValue)
    }
}
