//
//  AKThreePoleLowpassFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKThreePoleLowpassFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKThreePoleLowpassFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKThreePoleLowpassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var distortion: Double = 0.5 {
        didSet { setParameter(.distortion, value: distortion) }
    }
    var cutoffFrequency: Double = 1_500 {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }
    var resonance: Double = 0.5 {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createThreePoleLowpassFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let distortion = AUParameterTree.createParameter(
            withIdentifier: "distortion",
            name: "Distortion (%)",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 2.0,
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AUParameterAddress(1),
            min: 12.0,
            max: 20_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Resonance (%)",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 2.0,
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [distortion, cutoffFrequency, resonance]))
        distortion.value = 0.5
        cutoffFrequency.value = 1_500
        resonance.value = 0.5
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
