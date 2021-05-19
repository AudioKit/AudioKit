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
    public static func fmOscillator(baseFrequency: OperationParameter = 440,
                                    carrierMultiplier: OperationParameter = 1.0,
                                    modulatingMultiplier: OperationParameter = 1.0,
                                    modulationIndex: OperationParameter = 1.0,
                                    amplitude: OperationParameter = 0.5) -> Operation {
        return Operation(module: "fm",
                         inputs: baseFrequency, amplitude,
                         carrierMultiplier, modulatingMultiplier, modulationIndex)
    }

    /// Morphing Oscillator
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///   - index: Index of waveform 0.0 - 3.0 where 0 = sine, 1 = square, 2 = sawtooth, 3 = reversed sawtooth
    ///
    public static func morphingOscillator(frequency: OperationParameter = 440,
                                          amplitude: OperationParameter = 1,
                                          index: OperationParameter = 0) -> Operation {
        let sine     = #""sine" 4096 gen_sine "#
        let square   = #""square" 4096 "0 1 2047 1 2048 -1 4095 -1" gen_line "#
        let sawtooth = #""sawtooth" 4096 "0 -1 4095 1" gen_line "#
        let revsaw   = #""revsaw" 4096 "0 1 4095 -1" gen_line "#

        return Operation(module: #"3 / 0 "sine" "square" "sawtooth" "revsaw" oscmorph4"#,
                           setup: "\(sine) \(square) \(sawtooth) \(revsaw)",
            inputs: frequency, amplitude, index)
    }

    /// Produces a normalized sawtooth wave between the values of 0 and 1. Phasors
    /// are often used when building table-lookup oscillators.
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second, or Hz. (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - phase: Initial phase (Default: 0)
    ///
    public static func phasor(frequency: OperationParameter = 1, phase: Double = 0) -> Operation {
        return Operation(module: "phasor", inputs: frequency, phase)
    }

    /// Simple sawtooth oscillator, not-band limited, can be used for LFO or wave,
    /// but sawtoothWave is probably better for audio.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func sawtooth(frequency: OperationParameter = 440,
                                amplitude: OperationParameter = 0.5,
                                phase: OperationParameter = 0) -> Operation {
        return Operation(module: "\"sawtooth\" osc",
                         setup: "\"sawtooth\" 4096 \"0 -1 4095 1\" gen_line",
                         inputs: frequency, amplitude, phase)
    }

    /// Simple reverse sawtooth oscillator, not-band limited, can be used for LFO or wave.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func reverseSawtooth(frequency: OperationParameter = 440,
                                       amplitude: OperationParameter = 0.5,
                                       phase: OperationParameter = 0) -> Operation {
        return Operation(module: "\"revsaw\" osc",
                         setup: "\"revsaw\" 4096 \"0 1 4095 -1\" gen_line",
                         inputs: frequency, amplitude, phase)
    }

    /// Bandlimited sawtooth oscillator This is a bandlimited sawtooth oscillator
    /// ported from the "sawtooth" function from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func sawtoothWave(frequency: OperationParameter = 440,
                                    amplitude: OperationParameter = 0.5) -> Operation {
        return Operation(module: "blsaw", inputs: frequency, amplitude)
    }

    /// Standard Sine Wave
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///
    public static func sineWave(frequency: OperationParameter = 440,
                                amplitude: OperationParameter = 1) -> Operation {
        return Operation(module: "sine", inputs: frequency, amplitude)
    }

    /// Simple square oscillator, not-band limited, can be used for LFO or wave,
    /// but squareWave is probably better for audio.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func square(frequency: OperationParameter = 440,
                              amplitude: OperationParameter = 0.5,
                              phase: OperationParameter = 0) -> Operation {
        return Operation(module: "\"square\" osc",
                         setup: "\"square\" 4096 \"0 -1 2047 -1 2048 1 4095 1\" gen_line",
                         inputs: frequency, amplitude, phase)
    }

    /// This is a bandlimited square oscillator ported from the "square" function
    /// from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0, Maximum: 20000)
    ///   - amplitude: Output amplitude (Default: 1.0, Minimum: 0, Maximum: 10)
    ///   - pulseWidth: Duty cycle width. (Default: 0.5, Minimum: 0, Maximum: 1)
    ///
    public static func squareWave(frequency: OperationParameter = 440,
                                  amplitude: OperationParameter = 1.0,
                                  pulseWidth: OperationParameter = 0.5) -> Operation {
        return Operation(module: "blsquare",
                         inputs: frequency, amplitude, pulseWidth)
    }

    /// Simple triangle oscillator, not-band limited, can be used for LFO or wave,
    /// but triangleWave is probably better for audio.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func triangle(frequency: OperationParameter = 440,
                                amplitude: OperationParameter = 0.5,
                                phase: OperationParameter = 0) -> Operation {
        return Operation(module: "\"triangle\" osc",
                         setup: "\"triangle\" 4096 \"0 -1 2048 1 4096 -1\" gen_line",
                         inputs: frequency, amplitude, phase)
    }

    /// This is a bandlimited triangle oscillator
    /// ported from the "triangle" function from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func triangleWave(frequency: OperationParameter = 440,
                                    amplitude: OperationParameter = 0.5) -> Operation {
        return Operation(module: "bltriangle", inputs: frequency, amplitude)
    }
}
