// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Minimum of two operations
///
/// - Parameters:
///   - x: 1st operation
///   - y: 2nd operation
///
public func min(_ x: ComputedParameter, _ y: ComputedParameter) -> AKOperation {
    return AKOperation(module: "min", inputs: x.toMono(), y.toMono())
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ operation: ComputedParameter, _ parameter: OperationParameter) -> AKOperation {
    return AKOperation(module: "min", inputs: operation.toMono(), parameter)
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ parameter: OperationParameter, _ operation: ComputedParameter) -> AKOperation {
    return min(operation, parameter)
}
