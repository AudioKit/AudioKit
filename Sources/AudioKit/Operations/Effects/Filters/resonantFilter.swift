// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// A second-order resonant filter.
    ///
    /// - Parameters:
    ///   - frequency: The center frequency of the filter, or frequency position of the peak response
    ///                (defaults to 4000 Hz).
    ///   - bandwidth: The bandwidth of the filter (the Hz difference between the upper and lower half-power points
    ///                (defaults to 1000 Hz).
    ///
    public func resonantFilter(
        frequency: OperationParameter = 4_000.0,
        bandwidth: OperationParameter = 1_000.0
        ) -> Operation {
        return Operation(module: "reson", inputs: toMono(), frequency, bandwidth)
    }
}
