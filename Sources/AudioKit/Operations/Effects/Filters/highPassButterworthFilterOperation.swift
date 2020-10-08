// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 500, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassButterworthFilter(
        cutoffFrequency: OperationParameter = 500
        ) -> ComputedParameter {
        return Operation(module: "buthp", inputs: toMono(), cutoffFrequency)
    }
}
