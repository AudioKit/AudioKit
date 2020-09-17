// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// This will digitally degrade a signal.
    ///
    /// - Parameters:
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24).
    ///               Non-integer values are OK. (Default: 8, Minimum: 1, Maximum: 24)
    ///   - sampleRate: The sample rate of signal output. (Default: 10000, Minimum: 0.0, Maximum: 20000.0)
    ///
    public func bitCrush(
        bitDepth: OperationParameter = 8,
        sampleRate: OperationParameter = 10_000
        ) -> Operation {
        return Operation(module: "bitcrush",
                           inputs: toMono(), bitDepth, sampleRate)
    }
}
