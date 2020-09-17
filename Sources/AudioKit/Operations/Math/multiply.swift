// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    /// Multiplication of parameters
    ///
    /// - parameter parameter: The amount to multiply
    ///
    public func times(_ parameter: OperationParameter) -> Operation {
        return Operation(module: "*", inputs: self, parameter)
    }

    /// Offsetting by way of multiplication
    ///
    /// - parameter parameter: The amount to scale by
    ///
    public func scaledBy(_ parameter: OperationParameter) -> Operation {
        return self.times(parameter)
    }
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func * (left: OperationParameter, right: OperationParameter) -> Operation {
    return left.toMono().times(right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: stereo operation
///   - right: parameter
///
public func * (left: StereoOperation, right: OperationParameter) -> StereoOperation {
    return StereoOperation(module: "dup rot mul rot rot mul swap", inputs: left, right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: parameter
///   - right: stereo operation
///
public func * (left: OperationParameter, right: StereoOperation) -> StereoOperation {
    return StereoOperation(module: "rot dup rot mul rot rot mul swap", inputs: left, right)
}
