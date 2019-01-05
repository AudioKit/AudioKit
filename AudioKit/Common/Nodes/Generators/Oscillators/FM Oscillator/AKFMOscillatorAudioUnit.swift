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

        let baseFrequency = AUParameterTree.createParameter(
            identifier: "baseFrequency",
            name: "Base Frequency (Hz)",
            address: AKFMOscillatorParameter.baseFrequency.rawValue,
            min: Float(AKFMOscillator.baseFrequencyRange.lowerBound),
            max: Float(AKFMOscillator.baseFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let carrierMultiplier = AUParameterTree.createParameter(
            identifier: "carrierMultiplier",
            name: "Carrier Multiplier",
            address: AKFMOscillatorParameter.carrierMultiplier.rawValue,
            min: Float(AKFMOscillator.carrierMultiplierRange.lowerBound),
            max: Float(AKFMOscillator.carrierMultiplierRange.upperBound),
            unit: .generic,
            flags: .default)
        let modulatingMultiplier = AUParameterTree.createParameter(
            identifier: "modulatingMultiplier",
            name: "Modulating Multiplier",
            address: AKFMOscillatorParameter.modulatingMultiplier.rawValue,
            min: Float(AKFMOscillator.modulatingMultiplierRange.lowerBound),
            max: Float(AKFMOscillator.modulatingMultiplierRange.upperBound),
            unit: .generic,
            flags: .default)
        let modulationIndex = AUParameterTree.createParameter(
            identifier: "modulationIndex",
            name: "Modulation Index",
            address: AKFMOscillatorParameter.modulationIndex.rawValue,
            min: Float(AKFMOscillator.modulationIndexRange.lowerBound),
            max: Float(AKFMOscillator.modulationIndexRange.upperBound),
            unit: .generic,
            flags: .default)
        let amplitude = AUParameterTree.createParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKFMOscillatorParameter.amplitude.rawValue,
            min: Float(AKFMOscillator.amplitudeRange.lowerBound),
            max: Float(AKFMOscillator.amplitudeRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [baseFrequency, carrierMultiplier, modulatingMultiplier, modulationIndex, amplitude]))
        baseFrequency.value = Float(AKFMOscillator.defaultBaseFrequency)
        carrierMultiplier.value = Float(AKFMOscillator.defaultCarrierMultiplier)
        modulatingMultiplier.value = Float(AKFMOscillator.defaultModulatingMultiplier)
        modulationIndex.value = Float(AKFMOscillator.defaultModulationIndex)
        amplitude.value = Float(AKFMOscillator.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
