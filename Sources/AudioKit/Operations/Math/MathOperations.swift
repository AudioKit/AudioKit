// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    
    /// Keep track of the number of times a trigger has fired
    ///
    /// - Parameters:
    ///   - maximum: Largest value to hold before looping or being pinned to this value
    ///   - looping: If set to true, when the maximum is reaching, the count goes back to zero,
    ///              otherwise it stays at the maximum
    ///
    public func count(maximum: OperationParameter = 1_000_000, looping: Bool = true) -> Operation {
        return Operation(module: "count", inputs: toMono(), maximum, looping ? 0 : 1)
    }
    
    /// Division of parameters
    ///
    /// - parameter denominator: The amount to divide
    ///
    public func dividedBy(_ denominator: OperationParameter) -> Operation {
        return Operation(module: "/", inputs: self, denominator)
    }
    
    /// Increment a signal by a default value of 1
    ///
    /// - Parameters:
    ///   - on: When to increment
    ///   - by: Increment amount (Default: 1)
    ///   - minimum: Increment amount (Default: 1)
    ///   - maximum: Increment amount (Default: 1)
    ///
    public func increment(on trigger: OperationParameter,
                          by step: OperationParameter = 1.0,
                          minimum: OperationParameter = 0.0,
                          maximum: OperationParameter = 1_000_000) -> Operation {
        return Operation(module: "incr", inputs: trigger, step, minimum, maximum, toMono())
    }
    
    /// Offsetting by way of addition
    ///
    /// - parameter parameter: The amount to offset by
    ///
    public func offsetBy(_ parameter: OperationParameter) -> Operation {
        return self.plus(parameter)
    }

    /// Addition/Summation of operations
    ///
    /// - parameter parameter: The amount to add
    ///
    public func plus(_ parameter: OperationParameter) -> Operation {
        return Operation(module: "+", inputs: self, parameter)
    }
    
    /// This scales from -1 to 1 to a range defined by a minimum and maximum point in the input and output domain.
    ///
    /// - Parameters:
    ///   - minimum: Minimum value to scale to. (Default: 0)
    ///   - maximum: Maximum value to scale to. (Default: 1)
    ///
    public func scale(minimum: OperationParameter = 0,
                      maximum: OperationParameter = 1) -> Operation {
        return Operation(module: "biscale", inputs: self, minimum, maximum)
    }
    
    /// Offsetting by way of multiplication
    ///
    /// - parameter parameter: The amount to scale by
    ///
    public func scaledBy(_ parameter: OperationParameter) -> Operation {
        return self.times(parameter)
    }
    
    /// Subtraction of parameters
    ///
    /// - parameter subtrahend: The amount to subtract
    ///
    public func minus(_ subtrahend: OperationParameter) -> Operation {
        return Operation(module: "-", inputs: self, subtrahend)
    }
    
    /// Multiplication of parameters
    ///
    /// - parameter parameter: The amount to multiply
    ///
    public func times(_ parameter: OperationParameter) -> Operation {
        return Operation(module: "*", inputs: self, parameter)
    }
}

extension StereoOperation {
    /// Helper function for addition
    ///
    /// - Parameters:
    ///   - first: 1st parameter
    ///   - second: 2nd parameter
    ///
    public static func + (first: StereoOperation, second: StereoOperation) -> StereoOperation {
        return StereoOperation(module: "rot + rot rot +",
                               inputs: first.left(), first.right(), second.left(), second.right())
    }
}
