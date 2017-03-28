//
//  multiply.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {
    /// Multiplication of parameters
    ///
    /// - parameter parameter: The amount to multiply
    ///
    public func times(_ parameter: AKParameter) -> AKOperation {
        return AKOperation(module: "*", inputs: self, parameter)
    }

    /// Offsetting by way of multiplication
    ///
    /// - parameter parameter: The amount to scale by
    ///
    public func scaledBy(_ parameter: AKParameter) -> AKOperation {
        return self.times(parameter)
    }
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func * (left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().times(right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: stereo operation
///   - right: parameter
///
public func * (left: AKStereoOperation, right: AKParameter) -> AKStereoOperation {
    return AKStereoOperation(module: "dup rot mul rot rot mul swap", inputs: left, right)
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: parameter
///   - right: stereo operation
///
public func * (left: AKParameter, right: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation(module: "rot dup rot mul rot rot mul swap", inputs: left, right)
}
