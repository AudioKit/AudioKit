//
//  AKMorphingOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMorphingOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKMorphingOscillatorParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKMorphingOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = AKMorphingOscillator.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var amplitude: Double = AKMorphingOscillator.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var index: Double = AKMorphingOscillator.defaultIndex {
        didSet { setParameter(.index, value: index) }
    }

    var detuningOffset: Double = AKMorphingOscillator.defaultDetuningOffset {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }

    var detuningMultiplier: Double = AKMorphingOscillator.defaultDetuningMultiplier {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createMorphingOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Frequency (in Hz)",
            address: AUParameterAddress(0),
            min: Float(AKMorphingOscillator.frequencyRange.lowerBound),
            max: Float(AKMorphingOscillator.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude (typically a value between 0 and 1).",
            address: AUParameterAddress(1),
            min: Float(AKMorphingOscillator.amplitudeRange.lowerBound),
            max: Float(AKMorphingOscillator.amplitudeRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let index = AUParameterTree.createParameter(
            withIdentifier: "index",
            name: "Index of the wavetable to use (fractional are okay).",
            address: AUParameterAddress(2),
            min: Float(AKMorphingOscillator.indexRange.lowerBound),
            max: Float(AKMorphingOscillator.indexRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningOffset = AUParameterTree.createParameter(
            withIdentifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AUParameterAddress(3),
            min: Float(AKMorphingOscillator.detuningOffsetRange.lowerBound),
            max: Float(AKMorphingOscillator.detuningOffsetRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningMultiplier = AUParameterTree.createParameter(
            withIdentifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AUParameterAddress(4),
            min: Float(AKMorphingOscillator.detuningMultiplierRange.lowerBound),
            max: Float(AKMorphingOscillator.detuningMultiplierRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, amplitude, index, detuningOffset, detuningMultiplier]))
        frequency.value = Float(AKMorphingOscillator.defaultFrequency)
        amplitude.value = Float(AKMorphingOscillator.defaultAmplitude)
        index.value = Float(AKMorphingOscillator.defaultIndex)
        detuningOffset.value = Float(AKMorphingOscillator.defaultDetuningOffset)
        detuningMultiplier.value = Float(AKMorphingOscillator.defaultDetuningMultiplier)
    }

    public override var canProcessInPlace: Bool { return true } 

}
