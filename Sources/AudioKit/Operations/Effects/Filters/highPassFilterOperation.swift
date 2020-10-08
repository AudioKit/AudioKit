// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// A complement to the LowPassFilter.
    ///
    /// - parameter halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///                             (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassFilter(
        halfPowerPoint: OperationParameter = 1_000
        ) -> Operation {
        return Operation(module: "atone", inputs: toMono(), halfPowerPoint)
    }
}
