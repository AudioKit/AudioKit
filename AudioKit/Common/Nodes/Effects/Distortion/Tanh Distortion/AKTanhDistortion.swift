// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter public var pregain: AUValue

    /// Gain applied after waveshaping
    @Parameter public var postgain: AUValue

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    @Parameter public var positiveShapeParameter: AUValue

    /// Like the positive shape parameter, only for the negative part.
    @Parameter public var negativeShapeParameter: AUValue

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

            input?.connect(to: self)
        }
    }
}
