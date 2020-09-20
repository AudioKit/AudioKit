// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Scaled noise sent through a classic sample and hold module.
    ///
    /// - Parameters:
    ///   - minimum: Minimum value to use. (Default: 0)
    ///   - maximum: Maximum value to use. (Default: 1)
    ///   - updateFrequency: Frequency of randomization (in Hz) (Default: 10)
    ///
    public static func randomNumberPulse(
        minimum: OperationParameter = 0,
        maximum: OperationParameter = 1,
        updateFrequency: OperationParameter = 10
        ) -> Operation {
        return Operation(module: "randh",
                           inputs: minimum, maximum, updateFrequency)
    }
}
