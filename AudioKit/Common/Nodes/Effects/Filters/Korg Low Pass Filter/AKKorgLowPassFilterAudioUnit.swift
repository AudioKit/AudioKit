//
//  AKKorgLowPassFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKKorgLowPassFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKKorgLowPassFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKKorgLowPassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var cutoffFrequency: Double = 1000.0 {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }
    var resonance: Double = 1.0 {
        didSet { setParameter(.resonance, value: resonance) }
    }
    var saturation: Double = 0.0 {
        didSet { setParameter(.saturation, value: saturation) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createKorgLowPassFilterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Filter cutoff",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 22050.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Filter resonance (should be between 0-2)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 2.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let saturation = AUParameterTree.createParameter(
            withIdentifier: "saturation",
            name: "Filter saturation.",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 10.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        

        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, saturation]))
        cutoffFrequency.value = 1000.0
        resonance.value = 1.0
        saturation.value = 0.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
