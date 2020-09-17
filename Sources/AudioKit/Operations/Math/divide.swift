// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    /// Division of parameters
    ///
    /// - parameter denominator: The amount to divide
    ///
    public func dividedBy(_ denominator: OperationParameter) -> Operation {
        return Operation(module: "/", inputs: self, denominator)
    }
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
