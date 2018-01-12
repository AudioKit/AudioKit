//
//  AKRolandTB303FilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKRolandTB303FilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var cutoffFrequency: Double = 500 {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }
    var resonance: Double = 0.5 {
        didSet { setParameter(.resonance, value: resonance) }
    }
    var distortion: Double = 2.0 {
        didSet { setParameter(.distortion, value: distortion) }
    }
    var resonanceAsymmetry: Double = 0.5 {
        didSet { setParameter(.resonanceAsymmetry, value: resonanceAsymmetry) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createRolandTB303FilterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AUParameterAddress(0),
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
            name: "Resonance",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 2.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let distortion = AUParameterTree.createParameter(
            withIdentifier: "distortion",
            name: "Distortion",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 4.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonanceAsymmetry = AUParameterTree.createParameter(
            withIdentifier: "resonanceAsymmetry",
            name: "Resonance Asymmetry",
            address: AUParameterAddress(3),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, distortion, resonanceAsymmetry]))
        cutoffFrequency.value = 500
        resonance.value = 0.5
        distortion.value = 2.0
        resonanceAsymmetry.value = 0.5
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
