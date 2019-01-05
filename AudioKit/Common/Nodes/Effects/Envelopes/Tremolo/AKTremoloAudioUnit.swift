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

        let frequency = AUParameterTree.createParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKTremoloParameter.frequency.rawValue,
            min: Float(AKTremolo.frequencyRange.lowerBound),
            max: Float(AKTremolo.frequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let depth = AUParameterTree.createParameter(
            identifier: "depth",
            name: "Depth",
            address: AKTremoloParameter.depth.rawValue,
            min: Float(AKTremolo.depthRange.lowerBound),
            max: Float(AKTremolo.depthRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, depth]))
        frequency.value = Float(AKTremolo.defaultFrequency)
        depth.value = Float(AKTremolo.defaultDepth)
    }

    public override var canProcessInPlace: Bool { return true }

}
