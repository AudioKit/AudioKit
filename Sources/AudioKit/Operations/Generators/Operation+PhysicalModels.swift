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
    
    /// Karplus-Strong plucked string instrument.
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    /// NOTE:  This node is CPU intensitve and will drop packet if your buffer size is
    /// too short. It requires at least 64 samples on an iPhone X, for example.
    public static func vocalTract(
        frequency: OperationParameter = 160.0,
        tonguePosition: OperationParameter = 0.5,
        tongueDiameter: OperationParameter = 1.0,
        tenseness: OperationParameter = 0.6,
        nasality: OperationParameter = 0.0) -> Operation {

        return Operation(module: "voc",
                           inputs: frequency, tonguePosition, tongueDiameter, tenseness, nasality)
    }
}
