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

    var wah: Double = AKAutoWah.defaultWah {
        didSet { setParameter(.wah, value: wah) }
    }

    var mix: Double = AKAutoWah.defaultMix {
        didSet { setParameter(.mix, value: mix) }
    }

    var amplitude: Double = AKAutoWah.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createAutoWahDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let wah = AUParameterTree.createParameter(
            withIdentifier: "wah",
            name: "Wah Amount",
            address: AUParameterAddress(0),
            min: Float(AKAutoWah.wahRange.lowerBound),
            max: Float(AKAutoWah.wahRange.upperBound),
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
            min: Float(AKAutoWah.mixRange.lowerBound),
            max: Float(AKAutoWah.mixRange.upperBound),
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
            min: Float(AKAutoWah.amplitudeRange.lowerBound),
            max: Float(AKAutoWah.amplitudeRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [wah, mix, amplitude]))
        wah.value = Float(AKAutoWah.defaultWah)
        mix.value = Float(AKAutoWah.defaultMix)
        amplitude.value = Float(AKAutoWah.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true } 

}
