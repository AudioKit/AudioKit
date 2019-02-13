//
//  AKBitCrusherAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBitCrusherAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKBitCrusherParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKBitCrusherParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var bitDepth: Double = AKBitCrusher.defaultBitDepth {
        didSet { setParameter(.bitDepth, value: bitDepth) }
    }

    var sampleRate: Double = AKBitCrusher.defaultSampleRate {
        didSet { setParameter(.sampleRate, value: sampleRate) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createBitCrusherDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let bitDepth = AUParameter(
            identifier: "bitDepth",
            name: "Bit Depth",
            address: AKBitCrusherParameter.bitDepth.rawValue,
            range: AKBitCrusher.bitDepthRange,
            unit: .generic,
            flags: .default)
        let sampleRate = AUParameter(
            identifier: "sampleRate",
            name: "Sample Rate (Hz)",
            address: AKBitCrusherParameter.sampleRate.rawValue,
            range: AKBitCrusher.sampleRateRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [bitDepth, sampleRate]))
        bitDepth.value = Float(AKBitCrusher.defaultBitDepth)
        sampleRate.value = Float(AKBitCrusher.defaultSampleRate)
    }

    public override var canProcessInPlace: Bool { return true }

}
