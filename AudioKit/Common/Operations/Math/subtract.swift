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
        return AKOperation(module: "-", inputs: self, subtrahend)
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
    return AKStereoOperation(module: "rot swap - rot rot swap -",
                             inputs: first.left(), first.right(), second.left(), second.right())
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func -(x: AKParameter) -> AKOperation {
    return AKOperation(module: "0 swap -", inputs: x)
}

/// Negation
///
/// - parameter parameter: Parameter to negate
///
public prefix func -(x: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation(module: "0 swap - swap 0 swap - swap", inputs: x.left(), x.right())
    
}
