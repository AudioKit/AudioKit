// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

public class AKShakerAudioUnit: AKAudioUnitBase {

    var type: AUParameter!

    var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createShakerDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        type = AUParameter(
            identifier: "Type",
            name: "type",
            address: 0,
            range: 0...22,
            unit: .generic,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: 1,
            range: 0...10,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [type, amplitude])

        type.value = 0
        amplitude.value = 0.5
    }

    public func triggerType(_ type: AUValue, amplitude: AUValue) {
        triggerTypeShakerDSP(dsp, type, amplitude)
    }
}
