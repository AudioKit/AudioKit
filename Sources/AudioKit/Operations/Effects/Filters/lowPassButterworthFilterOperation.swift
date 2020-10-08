// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func lowPassButterworthFilter(
        cutoffFrequency: OperationParameter = 1_000
        ) -> Operation {
        return Operation(module: "butlp", inputs: toMono(), cutoffFrequency)
    }
}
