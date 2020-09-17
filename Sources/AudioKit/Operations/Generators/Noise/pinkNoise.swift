// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Faust-based pink noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0, Maximum: 1.0)
    ///
    public static func pinkNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "pinknoise", inputs: amplitude)
    }
}
