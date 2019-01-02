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

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Variable frequency. Values less than the initial frequency  will be doubled until it is greater than that.",
            address: AKPluckedStringParameter.frequency.rawValue,
            min: Float(AKPluckedString.frequencyRange.lowerBound),
            max: Float(AKPluckedString.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AKPluckedStringParameter.amplitude.rawValue,
            min: Float(AKPluckedString.amplitudeRange.lowerBound),
            max: Float(AKPluckedString.amplitudeRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, amplitude]))
        frequency.value = Float(AKPluckedString.defaultFrequency)
        amplitude.value = Float(AKPluckedString.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
