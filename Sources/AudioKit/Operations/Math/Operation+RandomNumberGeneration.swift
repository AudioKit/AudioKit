// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    
    /// A signal with random fluctuations
    /// This is useful for emulating jitter found in analogue equipment.
    ///
    /// - Parameters:
    ///   - amplitude: The amplitude of the line. Will produce values in the range of (+/-)amp. (Default: 0.5)
    ///   - minimumFrequency: The minimum frequency of change in Hz. (Default: 0.5)
    ///   - maximumFrequency: The maximum frequency of change in Hz. (Default: 4)
    ///
    public static func jitter(amplitude: OperationParameter = 0.5,
                              minimumFrequency: OperationParameter = 0.5,
                              maximumFrequency: OperationParameter = 4) -> Operation {
        return Operation(module: "jitter",
                         inputs: amplitude, minimumFrequency, maximumFrequency)
    }

    /// Scaled noise sent through a classic sample and hold module.
    ///
    /// - Parameters:
    ///   - minimum: Minimum value to use. (Default: 0)
    ///   - maximum: Maximum value to use. (Default: 1)
    ///   - updateFrequency: Frequency of randomization (in Hz) (Default: 10)
    ///
    public static func randomNumberPulse(minimum: OperationParameter = 0,
                                         maximum: OperationParameter = 1,
                                         updateFrequency: OperationParameter = 10) -> Operation {
        return Operation(module: "randh",
                         inputs: minimum, maximum, updateFrequency)
    }
    
    /// Line segments with vertices at random points
    ///
    /// - Parameters:
    ///   - minimum: Minimum value (Default: 0)
    ///   - maximum: Maximum value (Default: 1)
    ///   - updateFrequency: Frequency to change values. (Default: 3)
    ///
    public static func randomVertexPulse(minimum: OperationParameter = 0,
                                         maximum: OperationParameter = 1,
                                         updateFrequency: OperationParameter = 3) -> Operation {
        return Operation(module: "randi",
                         inputs: minimum, maximum, updateFrequency)
    }
}
