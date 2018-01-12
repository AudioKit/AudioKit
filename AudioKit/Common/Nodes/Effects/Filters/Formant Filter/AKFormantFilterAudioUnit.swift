//
//  AKFormantFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFormantFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKFormantFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKFormantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var centerFrequency: Double = 1000 {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }
    var attackDuration: Double = 0.007 {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }
    var decayDuration: Double = 0.04 {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFormantFilterDSP(Int32(count), sampleRate)
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
        let attackDuration = AUParameterTree.createParameter(
            withIdentifier: "attackDuration",
            name: "Impulse response attack time (Seconds)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 0.1,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let decayDuration = AUParameterTree.createParameter(
            withIdentifier: "decayDuration",
            name: "Impulse reponse decay time (Seconds)",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 0.1,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, attackDuration, decayDuration]))
        centerFrequency.value = 1000
        attackDuration.value = 0.007
        decayDuration.value = 0.04
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
