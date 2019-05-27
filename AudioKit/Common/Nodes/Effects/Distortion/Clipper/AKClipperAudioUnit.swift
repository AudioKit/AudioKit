//
//  AKClipperAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKClipperAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKClipperParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKClipperParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var limit: Double = AKClipper.defaultLimit {
        didSet { setParameter(.limit, value: limit) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createClipperDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let limit = AUParameter(
            identifier: "limit",
            name: "Threshold",
            address: AKClipperParameter.limit.rawValue,
            range: AKClipper.limitRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [limit]))
        limit.value = Float(AKClipper.defaultLimit)
    }

    public override var canProcessInPlace: Bool { return true }

}
