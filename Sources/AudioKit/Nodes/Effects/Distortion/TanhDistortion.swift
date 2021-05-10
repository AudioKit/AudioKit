// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// Distortion using a modified hyperbolic tangent function.
public class TanhDistortion: Node {

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate2(effect: "dist")

    // MARK: - Parameters

    /// Specification details for pregain
    public static let pregainDef = NodeParameterDef(
        identifier: "pregain",
        name: "Pregain",
        address: akGetParameterAddress("TanhDistortionParameterPregain"),
        defaultValue: 2.0,
        range: 0.0 ... 10.0,
        unit: .generic)

    /// Determines gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter(pregainDef) public var pregain: AUValue

    /// Specification details for postgain
    public static let postgainDef = NodeParameterDef(
        identifier: "postgain",
        name: "Postgain",
        address: akGetParameterAddress("TanhDistortionParameterPostgain"),
        defaultValue: 0.5,
        range: 0.0 ... 10.0,
        unit: .generic)

    /// Gain applied after waveshaping
    @Parameter(postgainDef) public var postgain: AUValue

    /// Specification details for positiveShapeParameter
    public static let positiveShapeParameterDef = NodeParameterDef(
        identifier: "positiveShapeParameter",
        name: "Positive Shape Parameter",
        address: akGetParameterAddress("TanhDistortionParameterPositiveShapeParameter"),
        defaultValue: 0.0,
        range: -10.0 ... 10.0,
        unit: .generic)

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    @Parameter(positiveShapeParameterDef) public var positiveShapeParameter: AUValue

    /// Specification details for negativeShapeParameter
    public static let negativeShapeParameterDef = NodeParameterDef(
        identifier: "negativeShapeParameter",
        name: "Negative Shape Parameter",
        address: akGetParameterAddress("TanhDistortionParameterNegativeShapeParameter"),
        defaultValue: 0.0,
        range: -10.0 ... 10.0,
        unit: .generic)

    /// Like the positive shape parameter, only for the negative part.
    @Parameter(negativeShapeParameterDef) public var negativeShapeParameter: AUValue

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pregain: Determines gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    ///   - postgain: Gain applied after waveshaping
    ///   - positiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    public init(
        _ input: Node,
        pregain: AUValue = pregainDef.defaultValue,
        postgain: AUValue = postgainDef.defaultValue,
        positiveShapeParameter: AUValue = positiveShapeParameterDef.defaultValue,
        negativeShapeParameter: AUValue = negativeShapeParameterDef.defaultValue
        ) {
        self.input = input

        setupParameters()

        self.pregain = pregain
        self.postgain = postgain
        self.positiveShapeParameter = positiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter
   }
}
