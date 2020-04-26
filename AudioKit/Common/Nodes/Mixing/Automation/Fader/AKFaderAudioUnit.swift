// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFaderAudioUnit: AKAudioUnitBase {

    var taper: AUParameter!

    var skew: AUParameter!

    var offset: AUParameter!

    var leftGain: AUParameter!

    var rightGain: AUParameter!

    var flipStereo: AUParameter!

    var mixToMono: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFaderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        leftGain = AUParameter(
            identifier: "leftGain",
            name: "Left Gain",
            address: 0,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default
        )

        rightGain = AUParameter(
            identifier: "rightGain",
            name: "Right Gain",
            address: 1,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default
        )

        taper = AUParameter(
            identifier: "taper",
            name: "Taper",
            address: 2,
            range: 0.1 ... 10.0,
            unit: .generic,
            flags: .default
        )

        skew = AUParameter(
            identifier: "skew",
            name: "Skew",
            address: 3,
            range: 0.0 ... 1.0,
            unit: .generic,
            flags: .default
        )

        offset = AUParameter(
            identifier: "offset",
            name: "Offset",
            address: 4,
            range: 0.0 ... 1_000_000_000.0,
            unit: .generic,
            flags: .default
        )

        flipStereo = AUParameter(
            identifier: "flipStereo",
            name: "Flip Stereo",
            address: 5,
            range: 0.0 ... 1.0,
            unit: .boolean,
            flags: .default
        )

        mixToMono = AUParameter(
            identifier: "mixToMono",
            name: "Mix To Stereo",
            address: 6,
            range: 0.0 ... 1.0,
            unit: .boolean,
            flags: .default
        )

        parameterTree = AUParameterTree.createTree(withChildren: [leftGain,
                                                                  rightGain,
                                                                  taper,
                                                                  skew,
                                                                  offset,
                                                                  flipStereo,
                                                                  mixToMono])

        leftGain.value = 1.0
        rightGain.value = 1.0
        taper.value = 1.0
        skew.value = 0.0
        offset.value = 0.0
        flipStereo.value = 0.0
        mixToMono.value = 0.0
    }
}
