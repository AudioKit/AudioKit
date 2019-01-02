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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKPannerParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let pan = AUParameterTree.createParameter(
            withIdentifier: "pan",
            name: "Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.",
            address: AKPannerParameter.pan.rawValue,
            min: Float(AKPanner.panRange.lowerBound),
            max: Float(AKPanner.panRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        
        setParameterTree(AUParameterTree.createTree(withChildren: [pan]))
        pan.value = Float(AKPanner.defaultPan)
    }

    public override var canProcessInPlace: Bool { return true }

}
