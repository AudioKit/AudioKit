// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    /// Subtraction of parameters
    ///
    /// - parameter subtrahend: The amount to subtract
    ///
    public func minus(_ subtrahend: OperationParameter) -> Operation {
        return Operation(module: "-", inputs: self, subtrahend)
    }
}

/// Helper function for Subtraction
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func - (left: OperationParameter, right: OperationParameter) -> Operation {
    return left.toMono().minus(right)
}

/// Helper function for subtraction
///
/// - Parameters:
///   - first: 1st parameter
///   - second: 2nd parameter
///
public func - (first: StereoOperation, second: StereoOperation) -> StereoOperation {
    return StereoOperation(module: "rot swap - rot rot swap -",
                             inputs: first.left(), first.right(), second.left(), second.right())
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func - (x: OperationParameter) -> Operation {
    return Operation(module: "0 swap -", inputs: x)
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func - (x: StereoOperation) -> StereoOperation {
    return StereoOperation(module: "0 swap - swap 0 swap - swap", inputs: x.left(), x.right())

}
