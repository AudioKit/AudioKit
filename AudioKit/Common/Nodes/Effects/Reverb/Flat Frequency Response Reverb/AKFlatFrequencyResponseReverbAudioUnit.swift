// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFlatFrequencyResponseReverbAudioUnit: AKAudioUnitBase {

    private(set) var reverbDuration: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFlatFrequencyResponseReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        reverbDuration = AUParameter(
            identifier: "reverbDuration",
            name: "Reverb Duration (Seconds)",
            address: AKFlatFrequencyResponseReverbParameter.reverbDuration.rawValue,
            range: AKFlatFrequencyResponseReverb.reverbDurationRange,
            unit: .seconds,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [reverbDuration])

        reverbDuration.value = AUValue(AKFlatFrequencyResponseReverb.defaultReverbDuration)
    }

    public func setLoopDuration(_ loopDuration: Float) {
        setLoopDurationFlatFrequencyResponseReverbDSP(dsp, loopDuration)
    }
}
