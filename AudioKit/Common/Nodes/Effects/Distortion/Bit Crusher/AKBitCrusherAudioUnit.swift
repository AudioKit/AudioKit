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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKBitCrusherParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var bitDepth: Double = 8 {
        didSet { setParameter(.bitDepth, value: bitDepth) }
    }
    var sampleRate: Double = 10_000 {
        didSet { setParameter(.sampleRate, value: sampleRate) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createBitCrusherDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let bitDepth = AUParameterTree.createParameter(
            withIdentifier: "bitDepth",
            name: "Bit Depth",
            address: AUParameterAddress(0),
            min: 1,
            max: 24,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let sampleRate = AUParameterTree.createParameter(
            withIdentifier: "sampleRate",
            name: "Sample Rate (Hz)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 20_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [bitDepth, sampleRate]))
        bitDepth.value = 8
        sampleRate.value = 10_000
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
