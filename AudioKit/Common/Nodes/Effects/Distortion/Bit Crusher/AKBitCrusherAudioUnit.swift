//
//  AKBitCrusherAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBitCrusherAudioUnit: AKAudioUnitBase {

    private(set) var bitDepth: AUParameter!

    private(set) var sampleRate: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createBitCrusherDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        bitDepth = AUParameter(
            identifier: "bitDepth",
            name: "Bit Depth",
            address: AKBitCrusherParameter.bitDepth.rawValue,
            range: AKBitCrusher.bitDepthRange,
            unit: .generic,
            flags: .default)
        sampleRate = AUParameter(
            identifier: "sampleRate",
            name: "Sample Rate (Hz)",
            address: AKBitCrusherParameter.sampleRate.rawValue,
            range: AKBitCrusher.sampleRateRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [bitDepth, sampleRate])

        bitDepth.value = AUValue(AKBitCrusher.defaultBitDepth)
        sampleRate.value = AUValue(AKBitCrusher.defaultSampleRate)
    }
}
