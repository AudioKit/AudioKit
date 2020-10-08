// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// This is a bandlimited triangle oscillator
    /// ported from the "triangle" function from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func triangleWave(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 0.5
        ) -> Operation {
        return Operation(module: "bltriangle", inputs: frequency, amplitude)
    }
}
