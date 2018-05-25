//
//  AKMoogLadderAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadderAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKMoogLadderParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKMoogLadderParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var cutoffFrequency: Double = AKMoogLadder.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKMoogLadder.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createMoogLadderDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKMoogLadder.cutoffFrequencyRange.lowerBound),
            max: Float(AKMoogLadder.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Resonance (%)",
            address: AUParameterAddress(1),
            min: Float(AKMoogLadder.resonanceRange.lowerBound),
            max: Float(AKMoogLadder.resonanceRange.upperBound),
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance]))
        cutoffFrequency.value = Float(AKMoogLadder.defaultCutoffFrequency)
        resonance.value = Float(AKMoogLadder.defaultResonance)
    }

    public override var canProcessInPlace: Bool { return true } 

}
