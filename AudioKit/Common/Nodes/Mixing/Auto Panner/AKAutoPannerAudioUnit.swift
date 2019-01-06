//
//  AKAutoPannerAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKAutoPannerAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKAutoPannerParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKAutoPannerParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = 10.0 {
        didSet { setParameter(.frequency, value: frequency) }
    }
    var depth: Double = 1.0 {
        didSet { setParameter(.depth, value: depth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAutoPannerDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: 0,
            range: 0.0...100.0,
            unit: .hertz,
            flags: .default)
        let depth = AUParameter(
            identifier: "depth",
            name: "Depth",
            address: 1,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, depth]))
        frequency.value = 10.0
        depth.value = 1.0
    }

    public override var canProcessInPlace: Bool { return true }

}
