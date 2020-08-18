// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKOperation {

    /// Loosely based off of the Csound opcode randomh. The design is equivalent to
    /// scaled noise sent through a classic sample and hold module.
    ///
    /// - Parameters:
    ///   - minimum: Minimum value to use. (Default: 0)
    ///   - maximum: Maximum value to use. (Default: 1)
    ///   - updateFrequency: Frequency of randomization (in Hz) (Default: 10)
    ///
    public static func randomNumberPulse(
        minimum: AKParameter = 0,
        maximum: AKParameter = 1,
        updateFrequency: AKParameter = 10
        ) -> AKOperation {
        return AKOperation(module: "randh",
                           inputs: minimum, maximum, updateFrequency)
    }
}
