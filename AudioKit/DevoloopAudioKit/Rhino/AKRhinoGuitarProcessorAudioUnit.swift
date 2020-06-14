// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

public class AKRhinoGuitarProcessorAudioUnit: AKAudioUnitBase {

    private(set) var preGain: AUParameter!

    private(set) var postGain: AUParameter!

    private(set) var lowGain: AUParameter!

    private(set) var midGain: AUParameter!

    private(set) var highGain: AUParameter!

    private(set) var distortion: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createRhinoGuitarProcessorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        preGain = AUParameter(
            identifier: "preGain",
            name: "PreGain",
            address: AKRhinoGuitarProcessorParameter.preGain.rawValue,
            range: 0.0 ... 10.0,
            unit: .generic,
            flags: .default)

        postGain = AUParameter(
            identifier: "postGain",
            name: "PostGain",
            address: AKRhinoGuitarProcessorParameter.postGain.rawValue,
            range: 0.0 ... 1.0,
            unit: .linearGain,
            flags: .default)

        lowGain = AUParameter(
            identifier: "lowGain",
            name: "Low Frequency Gain",
            address: AKRhinoGuitarProcessorParameter.lowGain.rawValue,
            range: -1.0 ... 1.0,
            unit: .generic,
            flags: .default)

        midGain = AUParameter(
            identifier: "midGain",
            name: "Mid Frequency Gain",
            address: AKRhinoGuitarProcessorParameter.midGain.rawValue,
            range: -1.0 ... 1.0,
            unit: .generic,
            flags: .default)

        highGain = AUParameter(
            identifier: "highGain",
            name: "High Frequency Gain",
            address: AKRhinoGuitarProcessorParameter.highGain.rawValue,
            range: -1.0 ... 1.0,
            unit: .generic,
            flags: .default)

        distortion = AUParameter(
            identifier: "distortion",
            name: "Distortion Amount",
            address: AKRhinoGuitarProcessorParameter.distortion.rawValue,
            range: 1.0 ... 20.0,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [preGain,
                                                                  postGain,
                                                                  lowGain,
                                                                  midGain,
                                                                  highGain,
                                                                  distortion])

        preGain.value = 5.0
        postGain.value = 0.7
        lowGain.value = 0.0
        midGain.value = 0.0
        highGain.value = 0.0
        distortion.value = 1.0
    }
}
