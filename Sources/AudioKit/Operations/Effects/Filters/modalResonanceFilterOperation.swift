// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// A modal resonance filter used for modal synthesis. Plucked and bell sounds
    /// can be created using  passing an impulse through a combination of modal
    /// filters.
    ///
    /// - Parameters:
    ///   - frequency: Resonant frequency of the filter. (Default: 500.0, Minimum: 12.0, Maximum: 20000.0)
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///                    (Default: 50.0, Minimum: 0.0, Maximum: 100.0)
    ///
    public func modalResonanceFilter(
        frequency: OperationParameter = 500.0,
        qualityFactor: OperationParameter = 50.0
        ) -> Operation {
        return Operation(module: "mode", inputs: toMono(), frequency, qualityFactor)
    }
}
