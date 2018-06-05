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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKTanhDistortionParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createTanhDistortionDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let pregain = AUParameterTree.createParameter(
            withIdentifier: "pregain",
            name: "Pregain",
            address: AUParameterAddress(0),
            min: Float(AKTanhDistortion.pregainRange.lowerBound),
            max: Float(AKTanhDistortion.pregainRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let postgain = AUParameterTree.createParameter(
            withIdentifier: "postgain",
            name: "Postgain",
            address: AUParameterAddress(1),
            min: Float(AKTanhDistortion.postgainRange.lowerBound),
            max: Float(AKTanhDistortion.postgainRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let positiveShapeParameter = AUParameterTree.createParameter(
            withIdentifier: "positiveShapeParameter",
            name: "Positive Shape Parameter",
            address: AUParameterAddress(2),
            min: Float(AKTanhDistortion.positiveShapeParameterRange.lowerBound),
            max: Float(AKTanhDistortion.positiveShapeParameterRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let negativeShapeParameter = AUParameterTree.createParameter(
            withIdentifier: "negativeShapeParameter",
            name: "Negative Shape Parameter",
            address: AUParameterAddress(3),
            min: Float(AKTanhDistortion.negativeShapeParameterRange.lowerBound),
            max: Float(AKTanhDistortion.negativeShapeParameterRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [pregain, postgain, positiveShapeParameter, negativeShapeParameter]))
        pregain.value = Float(AKTanhDistortion.defaultPregain)
        postgain.value = Float(AKTanhDistortion.defaultPostgain)
        positiveShapeParameter.value = Float(AKTanhDistortion.defaultPositiveShapeParameter)
        negativeShapeParameter.value = Float(AKTanhDistortion.defaultNegativeShapeParameter)
    }

    public override var canProcessInPlace: Bool { return true } 

}
