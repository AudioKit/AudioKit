// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import AudioKit

public class SDBoosterAudioUnit: AKAudioUnitBase {

    let leftGain = AUParameter(
        identifier: "leftGain",
        name: "Left Boosting Amount",
        address: 0,
        range: 0.0...2.0,
        unit: .linearGain,
        flags: .default)

    let rightGain = AUParameter(
        identifier: "rightGain",
        name: "Right Boosting Amount",
        address: 1,
        range: 0.0...2.0,
        unit: .linearGain,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createSDBoosterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [leftGain, rightGain])
    }
}
