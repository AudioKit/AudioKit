// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Brownian noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0, Maximum: 1.0)
    ///
    public static func brownianNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "brown *", inputs: amplitude)
    }
    
    /// Faust-based pink noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0, Maximum: 1.0)
    ///
    public static func pinkNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "pinknoise", inputs: amplitude)
    }
    
    /// White noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func whiteNoise(amplitude: OperationParameter = 1.0) -> Operation {
        return Operation(module: "noise", inputs: amplitude)
    }
}
