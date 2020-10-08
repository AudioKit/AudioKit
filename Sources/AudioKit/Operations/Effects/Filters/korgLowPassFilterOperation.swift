// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Analogue model of the Korg 35 Lowpass Filter
    ///
    /// - returns: Operation
    /// - parameter input: Input audio signal
    /// - parameter cutoffFrequency: Filter cutoff (Default: 1000.0, Minimum: 0.0, Maximum: 22050.0)
    /// - parameter resonance: Filter resonance (should be between 0-2) (Default: 1.0, Minimum: 0.0, Maximum: 2.0)
    /// - parameter saturation: Filter saturation. (Default: 0.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public func korgLowPassFilter(
        cutoffFrequency: OperationParameter = 1_000.0,
        resonance: OperationParameter = 1.0,
        saturation: OperationParameter = 0.0
        ) -> Operation {
        return Operation(module: "wpkorg35",
                           inputs: toMono(), cutoffFrequency, resonance, saturation)
    }
}
