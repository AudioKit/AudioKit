// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Karplus-Strong plucked string instrument.
    ///
    /// - Parameters:
    ///   - trigger: Triggering operation
    ///   - frequency: Variable frequency. Values less than the lowest frequency will be doubled until it is
    ///                greater than that. (Default: 110, Minimum: 0, Maximum: 22000)
    ///   - amplitude: Amplitude (Default: 0.5, Minimum: 0, Maximum: 1)
    ///   - lowestFrequency: Sets the initial frequency. This frequency is used to allocate all the buffers needed for
    ///                      the delay. This should be the lowest frequency you plan on using. (Default: 110)
    ///
    public static func pluckedString(
        trigger: Operation,
        frequency: OperationParameter = 110,
        amplitude: OperationParameter = 0.5,
        lowestFrequency: Double = 110
        ) -> Operation {
        return Operation(module: "pluck",
                           inputs: trigger, frequency, amplitude, lowestFrequency)
    }
}
