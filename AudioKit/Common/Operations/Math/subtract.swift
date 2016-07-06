//
//  subtract.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Subtraction of parameters
    ///
    /// - parameter subtrahend: The amount to subtract
    ///
    public func minus(subtrahend: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(subtrahend) -)")
    }
}


/// Helper function for Subtraction
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func -(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().minus(right)
}

/// Helper function for subtraction
///
/// - Parameters:
///   - first: 1st parameter
///   - second: 2nd parameter
///
public func -(first: AKStereoOperation, second: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation("\(first.left()) \(second.left()) - \(first.right()) \(second.right()) -")
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func -(x: AKParameter) -> AKOperation {
    return AKOperation("(0 \(x) -)")
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func -(x: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation("(0 \(x.left()) -) (0 \(x.right()) -)")
}
