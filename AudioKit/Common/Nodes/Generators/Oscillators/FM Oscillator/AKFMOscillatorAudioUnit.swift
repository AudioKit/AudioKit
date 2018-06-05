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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFMOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let baseFrequency = AUParameterTree.createParameter(
            withIdentifier: "baseFrequency",
            name: "Base Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKFMOscillator.baseFrequencyRange.lowerBound),
            max: Float(AKFMOscillator.baseFrequencyRange.upperBound),
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
            min: Float(AKFMOscillator.carrierMultiplierRange.lowerBound),
            max: Float(AKFMOscillator.carrierMultiplierRange.upperBound),
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
            min: Float(AKFMOscillator.modulatingMultiplierRange.lowerBound),
            max: Float(AKFMOscillator.modulatingMultiplierRange.upperBound),
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
            min: Float(AKFMOscillator.modulationIndexRange.lowerBound),
            max: Float(AKFMOscillator.modulationIndexRange.upperBound),
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
            min: Float(AKFMOscillator.amplitudeRange.lowerBound),
            max: Float(AKFMOscillator.amplitudeRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [baseFrequency, carrierMultiplier, modulatingMultiplier, modulationIndex, amplitude]))
        baseFrequency.value = Float(AKFMOscillator.defaultBaseFrequency)
        carrierMultiplier.value = Float(AKFMOscillator.defaultCarrierMultiplier)
        modulatingMultiplier.value = Float(AKFMOscillator.defaultModulatingMultiplier)
        modulationIndex.value = Float(AKFMOscillator.defaultModulationIndex)
        amplitude.value = Float(AKFMOscillator.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true } 

}
