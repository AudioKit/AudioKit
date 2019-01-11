//
//  AKTremoloAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKTremoloAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKTremoloParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKTremoloParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKTremolo.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var depth: Double = AKTremolo.defaultDepth {
        didSet { setParameter(.depth, value: depth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createTremoloDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKTremoloParameter.frequency.rawValue,
            range: AKTremolo.frequencyRange,
            unit: .hertz,
            flags: .default)
        let depth = AUParameter(
            identifier: "depth",
            name: "Depth",
            address: AKTremoloParameter.depth.rawValue,
            range: AKTremolo.depthRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, depth]))
        frequency.value = Float(AKTremolo.defaultFrequency)
        depth.value = Float(AKTremolo.defaultDepth)
    }

    public override var canProcessInPlace: Bool { return true }

}
