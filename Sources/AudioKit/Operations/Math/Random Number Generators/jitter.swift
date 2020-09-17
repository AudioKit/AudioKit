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
    public static func jitter(
        amplitude: OperationParameter = 0.5,
        minimumFrequency: OperationParameter = 0.5,
        maximumFrequency: OperationParameter = 4
        ) -> Operation {
        return Operation(module: "jitter",
                           inputs: amplitude, minimumFrequency, maximumFrequency)
    }
}
