//
//  AKFMOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFMOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKFMOscillatorParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKFMOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var baseFrequency: Double = 440 {
        didSet { setParameter(.baseFrequency, value: baseFrequency) }
    }
    var carrierMultiplier: Double = 1.0 {
        didSet { setParameter(.carrierMultiplier, value: carrierMultiplier) }
    }
    var modulatingMultiplier: Double = 1 {
        didSet { setParameter(.modulatingMultiplier, value: modulatingMultiplier) }
    }
    var modulationIndex: Double = 1 {
        didSet { setParameter(.modulationIndex, value: modulationIndex) }
    }
    var amplitude: Double = 1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFMOscillatorDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let baseFrequency = AUParameterTree.createParameter(
            withIdentifier: "baseFrequency",
            name: "Base Frequency (Hz)",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 20_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let carrierMultiplier = AUParameterTree.createParameter(
            withIdentifier: "carrierMultiplier",
            name: "Carrier Multiplier",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 1_000.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let modulatingMultiplier = AUParameterTree.createParameter(
            withIdentifier: "modulatingMultiplier",
            name: "Modulating Multiplier",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 1_000.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let modulationIndex = AUParameterTree.createParameter(
            withIdentifier: "modulationIndex",
            name: "Modulation Index",
            address: AUParameterAddress(3),
            min: 0.0,
            max: 1_000.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AUParameterAddress(4),
            min: 0.0,
            max: 10.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [baseFrequency, carrierMultiplier, modulatingMultiplier, modulationIndex, amplitude]))
        baseFrequency.value = 440
        carrierMultiplier.value = 1.0
        modulatingMultiplier.value = 1
        modulationIndex.value = 1
        amplitude.value = 1
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
