// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Distortion using a modified hyperbolic tangent function.
///
public class AKTanhDistortion: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let pregainDef = AKNodeParameterDef(
        identifier: "pregain",
        name: "Pregain",
        address: akGetParameterAddress("AKTanhDistortionParameterPregain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter public var pregain: AUValue

    public static let postgainDef = AKNodeParameterDef(
        identifier: "postgain",
        name: "Postgain",
        address: akGetParameterAddress("AKTanhDistortionParameterPostgain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Gain applied after waveshaping
    @Parameter public var postgain: AUValue

    public static let positiveShapeParameterDef = AKNodeParameterDef(
        identifier: "positiveShapeParameter",
        name: "Positive Shape Parameter",
        address: akGetParameterAddress("AKTanhDistortionParameterPositiveShapeParameter"),
        range: -10.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    @Parameter public var positiveShapeParameter: AUValue

    public static let negativeShapeParameterDef = AKNodeParameterDef(
        identifier: "negativeShapeParameter",
        name: "Negative Shape Parameter",
        address: akGetParameterAddress("AKTanhDistortionParameterNegativeShapeParameter"),
        range: -10.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Like the positive shape parameter, only for the negative part.
    @Parameter public var negativeShapeParameter: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKTanhDistortion.pregainDef,
             AKTanhDistortion.postgainDef,
             AKTanhDistortion.positiveShapeParameterDef,
             AKTanhDistortion.negativeShapeParameterDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKTanhDistortionDSP")
        }
    }

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
        _ input: AKNode? = nil,
        pregain: AUValue = 2.0,
        postgain: AUValue = 0.5,
        positiveShapeParameter: AUValue = 0.0,
        negativeShapeParameter: AUValue = 0.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.pregain = pregain
        self.postgain = postgain
        self.positiveShapeParameter = positiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }
}
