//
//  AKCostelloReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation

public class AKCostelloReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ addr: AKCostelloReverbParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(addr.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ addr: AKCostelloReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(addr.rawValue), value: Float(value))
    }

    var feedback: Double = 0.6 {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var cutoffFrequency: Double = 4_000.0 {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createCostelloReverbDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
        
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feeback",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency",
            address: AUParameterAddress(1),
            min: 12.0,
            max: 20_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        setParameterTree(AUParameterTree.createTree(withChildren: [feedback, cutoffFrequency]))
        feedback.value = 0.6
        cutoffFrequency.value = 4_000.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
