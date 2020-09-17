// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Standard Sine Wave
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///
    public static func sineWave(
        frequency: OperationParameter = 440,
        amplitude: OperationParameter = 1
        ) -> Operation {
        return Operation(module: "sine", inputs: frequency, amplitude)
    }
}
