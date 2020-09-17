// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    /// Addition/Summation of operations
    ///
    /// - parameter parameter: The amount to add
    ///
    public func plus(_ parameter: OperationParameter) -> Operation {
        return Operation(module: "+", inputs: self, parameter)
    }

    /// Offsetting by way of addition
    ///
    /// - parameter parameter: The amount to offset by
    ///
    public func offsetBy(_ parameter: OperationParameter) -> Operation {
        return self.plus(parameter)
    }
}

/// Helper function for addition
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func + (left: OperationParameter, right: OperationParameter) -> Operation {
    return left.toMono().plus(right)
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
