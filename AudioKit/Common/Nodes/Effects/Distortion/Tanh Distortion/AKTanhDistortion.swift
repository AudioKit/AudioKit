// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Pregain
    public static let pregainRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Postgain
    public static let postgainRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Positive Shape Parameter
    public static let positiveShapeParameterRange: ClosedRange<AUValue> = -10.0 ... 10.0

    /// Lower and upper bounds for Negative Shape Parameter
    public static let negativeShapeParameterRange: ClosedRange<AUValue> = -10.0 ... 10.0

    /// Initial value for Pregain
    public static let defaultPregain: AUValue = 2.0

    /// Initial value for Postgain
    public static let defaultPostgain: AUValue = 0.5

    /// Initial value for Positive Shape Parameter
    public static let defaultPositiveShapeParameter: AUValue = 0.0

    /// Initial value for Negative Shape Parameter
    public static let defaultNegativeShapeParameter: AUValue = 0.0

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    public let pregain = AKNodeParameter(identifier: "pregain")

    /// Gain applied after waveshaping
    public let postgain = AKNodeParameter(identifier: "postgain")

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    public let positiveShapeParameter = AKNodeParameter(identifier: "positiveShapeParameter")

    /// Like the positive shape parameter, only for the negative part.
    public let negativeShapeParameter = AKNodeParameter(identifier: "negativeShapeParameter")

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pregain: Gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    ///   - postgain: Gain applied after waveshaping
    ///   - positiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    public init(
        _ input: AKNode? = nil,
        pregain: AUValue = defaultPregain,
        postgain: AUValue = defaultPostgain,
        positiveShapeParameter: AUValue = defaultPositiveShapeParameter,
        negativeShapeParameter: AUValue = defaultNegativeShapeParameter
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.pregain.associate(with: self.internalAU, value: pregain)
            self.postgain.associate(with: self.internalAU, value: postgain)
            self.positiveShapeParameter.associate(with: self.internalAU, value: positiveShapeParameter)
            self.negativeShapeParameter.associate(with: self.internalAU, value: negativeShapeParameter)

            input?.connect(to: self)
        }
    }
}
