// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKDCBlockAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return createDCBlockDSP()
    }
}
