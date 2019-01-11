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
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKAutoWahParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAutoWahDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let wah = AUParameter(
            identifier: "wah",
            name: "Wah Amount",
            address: AKAutoWahParameter.wah.rawValue,
            range: AKAutoWah.wahRange,
            unit: .generic,
            flags: .default)
        let mix = AUParameter(
            identifier: "mix",
            name: "Dry/Wet Mix",
            address: AKAutoWahParameter.mix.rawValue,
            range: AKAutoWah.mixRange,
            unit: .percent,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Overall level",
            address: AKAutoWahParameter.amplitude.rawValue,
            range: AKAutoWah.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [wah, mix, amplitude]))
        wah.value = Float(AKAutoWah.defaultWah)
        mix.value = Float(AKAutoWah.defaultMix)
        amplitude.value = Float(AKAutoWah.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
