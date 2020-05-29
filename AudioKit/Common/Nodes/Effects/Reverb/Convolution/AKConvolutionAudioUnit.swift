// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKConvolutionAudioUnit: AKAudioUnitBase {

    public func setPartitionLength(_ length: Int) {
        setPartitionLengthConvolutionDSP(dsp, Int32(length))
    }

    public override func createDSP() -> AKDSPRef {
        return createConvolutionDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [])
    }
}
