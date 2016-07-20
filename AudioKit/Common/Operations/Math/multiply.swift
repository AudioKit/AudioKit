//
//  multiply.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Multiplication of parameters
    ///
    /// - parameter parameter: The amount to multiply
    ///
    public func times(parameter: AKParameter) -> AKOperation {
        return AKOperation(module: "*", inputs: self, parameter)
    }

    /// Offsetting by way of multiplication
    ///
    /// - parameter parameter: The amount to scale by
    ///
    public func scaledBy(parameter: AKParameter) -> AKOperation {
        return self.times(parameter)
    }
}

/// Helper function for Multiplication
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func *(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().times(right)
}

