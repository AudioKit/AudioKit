//
//  AKRhodesPianoAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKRhodesPianoAudioUnit: AKAudioUnitBase {

    var frequency: AUParameter!

    var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createRhodesPianoDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: 0,
            range: 0...20_000,
            unit: .hertz,
            flags: .default)
        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: 1,
            range: 0...10,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, amplitude])

        frequency.value = 440
        amplitude.value = 0.5
    }
}
