// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Clips a signal to a predefined limit, in a "soft" manner.
    ///
    /// - parameter limit: Threshold / limiting value. (Default: 1.0, Minimum: 0.0, Maximum: 1.0)
    ///
    public func clip(_ limit: OperationParameter = 1.0) -> Operation {
        return Operation(module: "clip", inputs: toMono(), limit)
    }
}
