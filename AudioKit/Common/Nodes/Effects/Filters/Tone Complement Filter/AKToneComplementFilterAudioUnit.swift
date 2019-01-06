//
//  AKToneComplementFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKToneComplementFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKToneComplementFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKToneComplementFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var halfPowerPoint: Double = AKToneComplementFilter.defaultHalfPowerPoint {
        didSet { setParameter(.halfPowerPoint, value: halfPowerPoint) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createToneComplementFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let halfPowerPoint = AUParameter(
            identifier: "halfPowerPoint",
            name: "Half-Power Point (Hz)",
            address: AKToneComplementFilterParameter.halfPowerPoint.rawValue,
            range: AKToneComplementFilter.halfPowerPointRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [halfPowerPoint]))
        halfPowerPoint.value = Float(AKToneComplementFilter.defaultHalfPowerPoint)
    }

    public override var canProcessInPlace: Bool { return true }

}
