//
//  AKAutoWahAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKAutoWahAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKAutoWahParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKAutoWahParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var wah: Double = 0.0 {
        didSet { setParameter(.wah, value: wah) }
    }
    var mix: Double = 1.0 {
        didSet { setParameter(.mix, value: mix) }
    }
    var amplitude: Double = 0.1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createAutoWahDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let wah = AUParameterTree.createParameter(
            withIdentifier: "wah",
            name: "Wah Amount",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let mix = AUParameterTree.createParameter(
            withIdentifier: "mix",
            name: "Dry/Wet Mix",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 1.0,
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Overall level",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [wah, mix, amplitude]))
        wah.value = 0.0
        mix.value = 1.0
        amplitude.value = 0.1
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
