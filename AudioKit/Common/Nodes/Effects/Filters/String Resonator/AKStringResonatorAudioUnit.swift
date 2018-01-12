//
//  AKStringResonatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKStringResonatorAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKStringResonatorParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKStringResonatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var fundamentalFrequency: Double = 100 {
        didSet { setParameter(.fundamentalFrequency, value: fundamentalFrequency) }
    }
    var feedback: Double = 0.95 {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createStringResonatorDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let fundamentalFrequency = AUParameterTree.createParameter(
            withIdentifier: "fundamentalFrequency",
            name: "Fundamental Frequency (Hz)",
            address: AUParameterAddress(0),
            min: 12.0,
            max: 10000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback (%)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        

        setParameterTree(AUParameterTree.createTree(withChildren: [fundamentalFrequency, feedback]))
        fundamentalFrequency.value = 100
        feedback.value = 0.95
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
