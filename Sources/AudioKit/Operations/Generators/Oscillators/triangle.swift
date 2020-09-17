// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Simple triangle oscillator, not-band limited, can be used for LFO or wave,
    /// but triangleWave is probably better for audio.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func triangle(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 0.5,
        phase: OperationParameter = 0
        ) -> Operation {
        return Operation(module: "\"triangle\" osc",
                           setup: "\"triangle\" 4096 \"0 -1 2048 1 4096 -1\" gen_line",
                           inputs: frequency, amplitude, phase)
    }
}
