// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKOperation {
    /// Multiplication of parameters
    ///
    /// - parameter parameter: The amount to multiply
    ///
    public func times(_ parameter: OperationParameter) -> AKOperation {
        return AKOperation(module: "*", inputs: self, parameter)
    }

    /// Offsetting by way of multiplication
    ///
    /// - parameter parameter: The amount to scale by
    ///
    public func scaledBy(_ parameter: OperationParameter) -> AKOperation {
        return self.times(parameter)
    }
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func * (left: OperationParameter, right: OperationParameter) -> AKOperation {
    return left.toMono().times(right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: stereo operation
///   - right: parameter
///
public func * (left: AKStereoOperation, right: OperationParameter) -> AKStereoOperation {
    return AKStereoOperation(module: "dup rot mul rot rot mul swap", inputs: left, right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: parameter
///   - right: stereo operation
///
public func * (left: OperationParameter, right: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation(module: "rot dup rot mul rot rot mul swap", inputs: left, right)
}
