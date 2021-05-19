// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Helper function for addition
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func + (left: OperationParameter, right: OperationParameter) -> Operation {
    return left.toMono().plus(right)
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

/// Helper function for Division
///
/// - Parameters:
///   - numerator: Mono parameter
///   - denominator: The amount to divide
///
public func / (numerator: OperationParameter, denominator: OperationParameter) -> Operation {
    return numerator.toMono().dividedBy(denominator)
}

/// Helper function for Division
///
/// - Parameters:
///   - numerator: Stereo operation
///   - denominator: The amount to divide
///
public func / (numerator: StereoOperation, denominator: OperationParameter) -> StereoOperation {
    return StereoOperation(module: "dup rot swap / rot rot / swap", inputs: numerator, denominator)
}

/// Performs absolute value on the operation
///
/// - parameter parameter: ComputedParameter to operate on
///
public func abs(_ parameter: Operation) -> Operation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - parameter operation: ComputedParameter to operate on
///
public func floor(_ operation: Operation) -> Operation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - parameter operation: ComputedParameter to operate on
///
public func fract(_ operation: Operation) -> Operation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - parameter operation: ComputedParameter to operate on
///
public func log(_ operation: Operation) -> Operation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - parmeter operation: ComputedParameter to operate on
///
public func log10(_ operation: Operation) -> Operation {
    return operation.log10()
}

/// Maximum of two operations
///
/// - Parameters:
///   - x: 1st operation
///   - y: 2nd operation
///
public func max(_ x: ComputedParameter, _ y: ComputedParameter) -> Operation {
    return Operation(module: "max", inputs: x, y)
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - operation: operation
///   - parameter: parameter
///
public func max(_ operation: ComputedParameter, _ parameter: OperationParameter) -> Operation {
    return Operation(module: "max", inputs: operation.toMono(), parameter)
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - parameter: parameter
///   - operation: operation
///
public func max(_ parameter: OperationParameter, _ operation: ComputedParameter) -> Operation {
    return max(operation.toMono(), parameter)
}

/// Minimum of two operations
///
/// - Parameters:
///   - x: 1st operation
///   - y: 2nd operation
///
public func min(_ x: ComputedParameter, _ y: ComputedParameter) -> Operation {
    return Operation(module: "min", inputs: x.toMono(), y.toMono())
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ operation: ComputedParameter, _ parameter: OperationParameter) -> Operation {
    return Operation(module: "min", inputs: operation.toMono(), parameter)
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ parameter: OperationParameter, _ operation: ComputedParameter) -> Operation {
    return min(operation, parameter)
}

/// Rounds the operation to the nearest integer
///
/// - parameter operation: ComputedParameter to operate on
///
public func round(_ operation: Operation) -> Operation {
    return operation.round()
}
