// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Brownian noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0, Maximum: 1.0)
    ///
    public static func brownianNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "brown *", inputs: amplitude)
    }
}
