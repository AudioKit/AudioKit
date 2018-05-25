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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKToneComplementFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var halfPowerPoint: Double = AKToneComplementFilter.defaultHalfPowerPoint {
        didSet { setParameter(.halfPowerPoint, value: halfPowerPoint) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createToneComplementFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let halfPowerPoint = AUParameterTree.createParameter(
            withIdentifier: "halfPowerPoint",
            name: "Half-Power Point (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKToneComplementFilter.halfPowerPointRange.lowerBound),
            max: Float(AKToneComplementFilter.halfPowerPointRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [halfPowerPoint]))
        halfPowerPoint.value = Float(AKToneComplementFilter.defaultHalfPowerPoint)
    }

    public override var canProcessInPlace: Bool { return true } 

}
