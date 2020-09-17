// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// White noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func whiteNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "noise", inputs: amplitude)
    }
}
