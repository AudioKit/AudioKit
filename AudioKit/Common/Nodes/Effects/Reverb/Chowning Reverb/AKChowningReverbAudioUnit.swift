// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKChowningReverbAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return createChowningReverbDSP()
    }
}
