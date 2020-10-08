// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Simple square oscillator, not-band limited, can be used for LFO or wave,
    /// but squareWave is probably better for audio.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func square(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 0.5,
        phase: OperationParameter = 0
        ) -> Operation {
        return Operation(module: "\"square\" osc",
                           setup: "\"square\" 4096 \"0 -1 2047 -1 2048 1 4095 1\" gen_line",
                           inputs: frequency, amplitude, phase)
    }
}
