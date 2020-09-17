// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Classic FM Synthesis audio generation.
    ///
    /// - Parameters:
    ///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating
    ///                    frequencies. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///                        (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///                           (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///                      (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func fmOscillator(
        baseFrequency: OperationParameter = 440,
        carrierMultiplier: OperationParameter = 1.0,
        modulatingMultiplier: OperationParameter = 1.0,
        modulationIndex: OperationParameter = 1.0,
        amplitude: OperationParameter = 0.5
        ) -> Operation {
        return Operation(module: "fm",
                           inputs: baseFrequency, amplitude,
                           carrierMultiplier, modulatingMultiplier, modulationIndex)
    }
}
