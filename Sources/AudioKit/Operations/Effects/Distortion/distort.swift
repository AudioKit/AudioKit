// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Distortion using a modified hyperbolic tangent function.
    ///
    /// - Parameters:
    ///   - pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives
    ///              slight distortion. (Default: 2.0, Minimum: 0.0, Maximum: 10.0)
    ///   - postgain: Gain applied after waveshaping (Default: 0.5, Minimum: 0.0, Maximum: 10.0)
    ///   - positiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///                            (Default: 0.0, Minimum: -10.0, Maximum: 10.0)
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///                             (Default: 0.0, Minimum: -10.0, Maximum: 10.0)
    ///
    public func distort(
        pregain: OperationParameter = 2.0,
        postgain: OperationParameter = 0.5,
        positiveShapeParameter: OperationParameter = 0.0,
        negativeShapeParameter: OperationParameter = 0.0
        ) -> Operation {
        return Operation(module: "dist",
                           inputs: toMono(), pregain, postgain, positiveShapeParameter, negativeShapeParameter)
    }
}
