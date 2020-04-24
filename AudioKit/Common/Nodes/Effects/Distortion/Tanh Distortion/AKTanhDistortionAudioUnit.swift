//
//  AKTanhDistortionAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKTanhDistortionAudioUnit: AKAudioUnitBase {

    private(set) var pregain: AUParameter!

    private(set) var postgain: AUParameter!

    private(set) var positiveShapeParameter: AUParameter!

    private(set) var negativeShapeParameter: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createTanhDistortionDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        pregain = AUParameter(
            identifier: "pregain",
            name: "Pregain",
            address: AKTanhDistortionParameter.pregain.rawValue,
            range: AKTanhDistortion.pregainRange,
            unit: .generic,
            flags: .default)
        postgain = AUParameter(
            identifier: "postgain",
            name: "Postgain",
            address: AKTanhDistortionParameter.postgain.rawValue,
            range: AKTanhDistortion.postgainRange,
            unit: .generic,
            flags: .default)
        positiveShapeParameter = AUParameter(
            identifier: "positiveShapeParameter",
            name: "Positive Shape Parameter",
            address: AKTanhDistortionParameter.positiveShapeParameter.rawValue,
            range: AKTanhDistortion.positiveShapeParameterRange,
            unit: .generic,
            flags: .default)
        negativeShapeParameter = AUParameter(
            identifier: "negativeShapeParameter",
            name: "Negative Shape Parameter",
            address: AKTanhDistortionParameter.negativeShapeParameter.rawValue,
            range: AKTanhDistortion.negativeShapeParameterRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [pregain, postgain, positiveShapeParameter, negativeShapeParameter])

        pregain.value = AUValue(AKTanhDistortion.defaultPregain)
        postgain.value = AUValue(AKTanhDistortion.defaultPostgain)
        positiveShapeParameter.value = AUValue(AKTanhDistortion.defaultPositiveShapeParameter)
        negativeShapeParameter.value = AUValue(AKTanhDistortion.defaultNegativeShapeParameter)
    }
}
