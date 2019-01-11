//
//  AKTanhDistortionAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKTanhDistortionAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKTanhDistortionParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKTanhDistortionParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var pregain: Double = AKTanhDistortion.defaultPregain {
        didSet { setParameter(.pregain, value: pregain) }
    }

    var postgain: Double = AKTanhDistortion.defaultPostgain {
        didSet { setParameter(.postgain, value: postgain) }
    }

    var positiveShapeParameter: Double = AKTanhDistortion.defaultPositiveShapeParameter {
        didSet { setParameter(.positiveShapeParameter, value: positiveShapeParameter) }
    }

    var negativeShapeParameter: Double = AKTanhDistortion.defaultNegativeShapeParameter {
        didSet { setParameter(.negativeShapeParameter, value: negativeShapeParameter) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createTanhDistortionDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let pregain = AUParameter(
            identifier: "pregain",
            name: "Pregain",
            address: AKTanhDistortionParameter.pregain.rawValue,
            range: AKTanhDistortion.pregainRange,
            unit: .generic,
            flags: .default)
        let postgain = AUParameter(
            identifier: "postgain",
            name: "Postgain",
            address: AKTanhDistortionParameter.postgain.rawValue,
            range: AKTanhDistortion.postgainRange,
            unit: .generic,
            flags: .default)
        let positiveShapeParameter = AUParameter(
            identifier: "positiveShapeParameter",
            name: "Positive Shape Parameter",
            address: AKTanhDistortionParameter.positiveShapeParameter.rawValue,
            range: AKTanhDistortion.positiveShapeParameterRange,
            unit: .generic,
            flags: .default)
        let negativeShapeParameter = AUParameter(
            identifier: "negativeShapeParameter",
            name: "Negative Shape Parameter",
            address: AKTanhDistortionParameter.negativeShapeParameter.rawValue,
            range: AKTanhDistortion.negativeShapeParameterRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [pregain, postgain, positiveShapeParameter, negativeShapeParameter]))
        pregain.value = Float(AKTanhDistortion.defaultPregain)
        postgain.value = Float(AKTanhDistortion.defaultPostgain)
        positiveShapeParameter.value = Float(AKTanhDistortion.defaultPositiveShapeParameter)
        negativeShapeParameter.value = Float(AKTanhDistortion.defaultNegativeShapeParameter)
    }

    public override var canProcessInPlace: Bool { return true }

}
