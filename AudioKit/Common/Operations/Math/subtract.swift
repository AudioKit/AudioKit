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
    /// - returns: AKOperation
    /// - parameter subtrahend: The amount to subtract
    ///
    public func minus(_ subtrahend: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(subtrahend) -)")
    }
}


/// Helper function for Subtraction
///
/// - returns: AKOperation
/// - left: 1st parameter
/// - right: 2nd parameter
///
public func -(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().minus(right)
}

public prefix func -(x: AKParameter) -> AKOperation {
    return AKOperation("(0 \(x) -)")
}
