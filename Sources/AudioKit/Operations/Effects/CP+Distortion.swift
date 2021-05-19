// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// This will digitally degrade a signal.
    ///
    /// - Parameters:
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24).
    ///               Non-integer values are OK. (Default: 8, Minimum: 1, Maximum: 24)
    ///   - sampleRate: The sample rate of signal output. (Default: 10000, Minimum: 0.0, Maximum: 20000.0)
    ///
    public func bitCrush(bitDepth: OperationParameter = 8,
                         sampleRate: OperationParameter = 10_000) -> Operation {
        return Operation(module: "bitcrush",
                         inputs: toMono(), bitDepth, sampleRate)
    }
    
    /// Clips a signal to a predefined limit, in a "soft" manner.
    ///
    /// - parameter limit: Threshold / limiting value. (Default: 1.0, Minimum: 0.0, Maximum: 1.0)
    ///
    public func clip(_ limit: OperationParameter = 1.0) -> Operation {
        return Operation(module: "clip", inputs: toMono(), limit)
    }
    
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
    public func distort(pregain: OperationParameter = 2.0,
                        postgain: OperationParameter = 0.5,
                        positiveShapeParameter: OperationParameter = 0.0,
                        negativeShapeParameter: OperationParameter = 0.0) -> Operation {
        return Operation(module: "dist",
                         inputs: toMono(), pregain, postgain, positiveShapeParameter, negativeShapeParameter)
    }
}
