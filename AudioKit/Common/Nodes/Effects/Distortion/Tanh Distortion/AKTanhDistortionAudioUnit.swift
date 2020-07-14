// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKTanhDistortionAudioUnit: AKAudioUnitBase {

    let pregain = AUParameter(
        identifier: "pregain",
        name: "Pregain",
        address: AKTanhDistortionParameter.pregain.rawValue,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let postgain = AUParameter(
        identifier: "postgain",
        name: "Postgain",
        address: AKTanhDistortionParameter.postgain.rawValue,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let positiveShapeParameter = AUParameter(
        identifier: "positiveShapeParameter",
        name: "Positive Shape Parameter",
        address: AKTanhDistortionParameter.positiveShapeParameter.rawValue,
        range: -10.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let negativeShapeParameter = AUParameter(
        identifier: "negativeShapeParameter",
        name: "Negative Shape Parameter",
        address: AKTanhDistortionParameter.negativeShapeParameter.rawValue,
        range: -10.0 ... 10.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createTanhDistortionDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [pregain,
                                                                  postgain,
                                                                  positiveShapeParameter,
                                                                  negativeShapeParameter])
    }
}
