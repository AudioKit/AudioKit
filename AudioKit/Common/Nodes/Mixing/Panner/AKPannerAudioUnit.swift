//
//  AKPannerAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPannerAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKPannerParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPannerParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var pan: Double = AKPanner.defaultPan {
        didSet { setParameter(.pan, value: pan) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPannerDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let pan = AUParameter(
            identifier: "pan",
            name: "Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.",
            address: AKPannerParameter.pan.rawValue,
            range: AKPanner.panRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [pan]))
        pan.value = Float(AKPanner.defaultPan)
    }

    public override var canProcessInPlace: Bool { return true }

}
