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
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKFMOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var baseFrequency: Double = AKFMOscillator.defaultBaseFrequency {
        didSet { setParameter(.baseFrequency, value: baseFrequency) }
    }

    var carrierMultiplier: Double = AKFMOscillator.defaultCarrierMultiplier {
        didSet { setParameter(.carrierMultiplier, value: carrierMultiplier) }
    }

    var modulatingMultiplier: Double = AKFMOscillator.defaultModulatingMultiplier {
        didSet { setParameter(.modulatingMultiplier, value: modulatingMultiplier) }
    }

    var modulationIndex: Double = AKFMOscillator.defaultModulationIndex {
        didSet { setParameter(.modulationIndex, value: modulationIndex) }
    }

    var amplitude: Double = AKFMOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFMOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let baseFrequency = AUParameter(
            identifier: "baseFrequency",
            name: "Base Frequency (Hz)",
            address: AKFMOscillatorParameter.baseFrequency.rawValue,
            range: AKFMOscillator.baseFrequencyRange,
            unit: .hertz,
            flags: .default)
        let carrierMultiplier = AUParameter(
            identifier: "carrierMultiplier",
            name: "Carrier Multiplier",
            address: AKFMOscillatorParameter.carrierMultiplier.rawValue,
            range: AKFMOscillator.carrierMultiplierRange,
            unit: .generic,
            flags: .default)
        let modulatingMultiplier = AUParameter(
            identifier: "modulatingMultiplier",
            name: "Modulating Multiplier",
            address: AKFMOscillatorParameter.modulatingMultiplier.rawValue,
            range: AKFMOscillator.modulatingMultiplierRange,
            unit: .generic,
            flags: .default)
        let modulationIndex = AUParameter(
            identifier: "modulationIndex",
            name: "Modulation Index",
            address: AKFMOscillatorParameter.modulationIndex.rawValue,
            range: AKFMOscillator.modulationIndexRange,
            unit: .generic,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKFMOscillatorParameter.amplitude.rawValue,
            range: AKFMOscillator.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [baseFrequency, carrierMultiplier, modulatingMultiplier, modulationIndex, amplitude]))
        baseFrequency.value = Float(AKFMOscillator.defaultBaseFrequency)
        carrierMultiplier.value = Float(AKFMOscillator.defaultCarrierMultiplier)
        modulatingMultiplier.value = Float(AKFMOscillator.defaultModulatingMultiplier)
        modulationIndex.value = Float(AKFMOscillator.defaultModulationIndex)
        amplitude.value = Float(AKFMOscillator.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
