// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKShakerAudioUnit: AKAudioUnitBase {

    public override func createDSP() -> AKDSPRef {
        return akCreateDSP("AKShakerDSP")
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [])
    }

    public func trigger(type: AUValue, amplitude: AUValue) {
        triggerTypeShakerDSP(dsp, type, amplitude)
    }
}
