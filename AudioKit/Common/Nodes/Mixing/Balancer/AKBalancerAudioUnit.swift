// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBalancerAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return createBalancerDSP()
    }
}
