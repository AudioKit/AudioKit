// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKDCBlockAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return createDCBlockDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        setParameterTree(AUParameterTree(children: []))
    }

    public override var canProcessInPlace: Bool { return true }

}
