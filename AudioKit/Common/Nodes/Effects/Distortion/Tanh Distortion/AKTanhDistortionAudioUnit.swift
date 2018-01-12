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

    var pregain: Double = 2.0 {
        didSet { setParameter(.pregain, value: pregain) }
    }
    var postgain: Double = 0.5 {
        didSet { setParameter(.postgain, value: postgain) }
    }
    var positiveShapeParameter: Double = 0.0 {
        didSet { setParameter(.positiveShapeParameter, value: positiveShapeParameter) }
    }
    var negativeShapeParameter: Double = 0.0 {
        didSet { setParameter(.negativeShapeParameter, value: negativeShapeParameter) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createTanhDistortionDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let pregain = AUParameterTree.createParameter(
            withIdentifier: "pregain",
            name: "Pregain",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 10.0,
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
            min: 0.0,
            max: 10.0,
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
            min: -10.0,
            max: 10.0,
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
            min: -10.0,
            max: 10.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [pregain, postgain, positiveShapeParameter, negativeShapeParameter]))
        pregain.value = 2.0
        postgain.value = 0.5
        positiveShapeParameter.value = 0.0
        negativeShapeParameter.value = 0.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
