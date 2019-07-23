//
//  AKFluteAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFluteAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKFluteParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKFluteParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = 440 {
        didSet { setParameter(.frequency, value: frequency) }
    }
    var amplitude: Double = 1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFluteDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: 0,
            range: 0...20_000,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: 1,
            range: 0...10,
            unit: .generic,
            flags: .default)
        setParameterTree(AUParameterTree(children: [frequency, amplitude]))
        frequency.value = 440
        amplitude.value = 1
    }

    public override var canProcessInPlace: Bool { return true }

}
