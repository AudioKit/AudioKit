// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKConvolutionAudioUnit: AKAudioUnitBase {

    public func setPartitionLength(_ length: Int) {
        setPartitionLengthConvolutionDSP(dsp, Int32(length))
    }

    public override func createDSP() -> AKDSPRef {
        return createConvolutionDSP()
    }
}
