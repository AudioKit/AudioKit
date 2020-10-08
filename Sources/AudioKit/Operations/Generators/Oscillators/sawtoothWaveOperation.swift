// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Bandlimited sawtooth oscillator This is a bandlimited sawtooth oscillator
    /// ported from the "sawtooth" function from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func sawtoothWave(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 0.5
        ) -> Operation {
        return Operation(module: "blsaw", inputs: frequency, amplitude)
    }
}
