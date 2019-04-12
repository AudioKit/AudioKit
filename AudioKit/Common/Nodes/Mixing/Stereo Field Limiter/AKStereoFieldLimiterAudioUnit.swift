//
//  AKStereoFieldLimiterAudioUnit.swift
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKStereoFieldLimiterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKStereoFieldLimiterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKStereoFieldLimiterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var amount: Double = 1.0 {
        didSet { setParameter(.amount, value: amount) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createStereoFieldLimiterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let amount = AUParameter(
            identifier: "amount",
            name: "Limiting amount",
            address: 0,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)
        setParameterTree(AUParameterTree(children: [amount]))
        amount.value = 1.0
    }

    public override var canProcessInPlace: Bool { return true }

}
