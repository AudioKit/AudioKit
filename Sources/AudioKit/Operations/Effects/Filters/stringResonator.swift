// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// A modal resonance filter used for modal synthesis. Plucked and bell sounds
    /// can be created using  passing an impulse through a combination of modal
    /// filters.
    ///
    /// - Parameters:
    ///   - frequency: Fundamental frequency of the filter. (Default: 100.0, Minimum: 12.0, Maximum: 20000.0)
    ///   - feedback: Feedback gain. A value close to 1 creates a slower decay and a more pronounced resonance.
    ///               Small values may leave the input signal unaffected. Depending on the filter frequency,
    ///               typical values are > .9.  Default 0.95
    ///
    public func stringResonator(
        frequency: OperationParameter = 100.0,
        feedback: OperationParameter = 0.95
        ) -> Operation {
        return Operation(module: "streson", inputs: toMono(), frequency, feedback)
    }
}
