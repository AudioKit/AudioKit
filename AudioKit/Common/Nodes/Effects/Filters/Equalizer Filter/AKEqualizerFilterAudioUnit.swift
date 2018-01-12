//
//  AKEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKEqualizerFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKEqualizerFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var centerFrequency: Double = 1000.0 {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }
    var bandwidth: Double = 100.0 {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }
    var gain: Double = 10.0 {
        didSet { setParameter(.gain, value: gain) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createEqualizerFilterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AUParameterAddress(0),
            min: 12.0,
            max: 20000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 20000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain (%)",
            address: AUParameterAddress(2),
            min: -100.0,
            max: 100.0,
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth, gain]))
        centerFrequency.value = 1000.0
        bandwidth.value = 100.0
        gain.value = 10.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
