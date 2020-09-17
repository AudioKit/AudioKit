// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Morphing Oscillator
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///   - index: Index of waveform 0.0 - 3.0 where 0 = sine, 1 = square, 2 = sawtooth, 3 = reversed sawtooth
    ///
    public static func morphingOscillator(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 1,
        index: OperationParameter = 0
        ) -> Operation {
        let sine     = #""sine" 4096 gen_sine "#
        let square   = #""square" 4096 "0 1 2047 1 2048 -1 4095 -1" gen_line "#
        let sawtooth = #""sawtooth" 4096 "0 -1 4095 1" gen_line "#
        let revsaw   = #""revsaw" 4096 "0 1 4095 -1" gen_line "#

        return Operation(module: #"3 / 0 "sine" "square" "sawtooth" "revsaw" oscmorph4"#,
                           setup: "\(sine) \(square) \(sawtooth) \(revsaw)",
            inputs: frequency, amplitude, index)
    }
}
