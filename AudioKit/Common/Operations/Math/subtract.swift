//
//  subtract.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Subtraction of parameters
    ///
    /// - returns: AKOperation
    /// - parameter subtrahend: The amount to subtract
    ///
    public func minus(subtrahend: AKParameter) -> AKOperation {
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

