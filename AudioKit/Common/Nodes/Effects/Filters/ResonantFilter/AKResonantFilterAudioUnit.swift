//
//  AKResonantFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKResonantFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKResonantFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKResonantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = 4_000.0 {
        didSet { setParameter(.frequency, value: frequency) }
    }
    var bandwidth: Double = 1_000.0 {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createResonantFilterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Center frequency of the filter, or frequency position of the peak response.",
            address: AUParameterAddress(0),
            min: 100.0,
            max: 20_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth of the filter.",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 10_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, bandwidth]))
        frequency.value = 4_000.0
        bandwidth.value = 1_000.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
