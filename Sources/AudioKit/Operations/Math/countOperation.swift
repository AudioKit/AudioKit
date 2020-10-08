// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Keep track of the number of times a trigger has fired
    ///
    /// - Parameters:
    ///   - maximum: Largest value to hold before looping or being pinned to this value
    ///   - looping: If set to true, when the maximum is reaching, the count goes back to zero,
    ///              otherwise it stays at the maximum
    ///
    public func count(maximum: OperationParameter = 1_000_000, looping: Bool = true) -> Operation {
        return Operation(module: "count", inputs: toMono(), maximum, looping ? 0 : 1)
    }
}
