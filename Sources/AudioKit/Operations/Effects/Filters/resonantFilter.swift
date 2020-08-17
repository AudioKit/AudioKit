// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// A second-order resonant filter.
    ///
    /// - Parameters:
    ///   - frequency: The center frequency of the filter, or frequency position of the peak response
    ///                (defaults to 4000 Hz).
    ///   - bandwidth: The bandwidth of the filter (the Hz difference between the upper and lower half-power points
    ///                (defaults to 1000 Hz).
    ///
    public func resonantFilter(
        frequency: AKParameter = 4_000.0,
        bandwidth: AKParameter = 1_000.0
        ) -> AKOperation {
        return AKOperation(module: "reson", inputs: toMono(), frequency, bandwidth)
    }
}
