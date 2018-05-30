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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKClipperParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var limit: Double = AKClipper.defaultLimit {
        didSet { setParameter(.limit, value: limit) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createClipperDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let limit = AUParameterTree.createParameter(
            withIdentifier: "limit",
            name: "Threshold",
            address: AUParameterAddress(0),
            min: Float(AKClipper.limitRange.lowerBound),
            max: Float(AKClipper.limitRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [limit]))
        limit.value = Float(AKClipper.defaultLimit)
    }

    public override var canProcessInPlace: Bool { return true } 

}
