//
//  AKPluckedStringAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPluckedStringAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPluckedStringParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPluckedStringParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKPluckedString.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKPluckedString.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPluckedStringDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Variable frequency. Values less than the initial frequency  will be doubled until it is greater than that.",
            address: AKPluckedStringParameter.frequency.rawValue,
            range: AKPluckedString.frequencyRange,
            unit: .hertz,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPluckedStringParameter.amplitude.rawValue,
            range: AKPluckedString.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, amplitude]))
        frequency.value = Float(AKPluckedString.defaultFrequency)
        amplitude.value = Float(AKPluckedString.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
