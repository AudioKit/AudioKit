//
//  add.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Addition/Summation of operations
    ///
    /// - parameter parameter: The amount to add
    ///
    public func plus(_ parameter: AKParameter) -> AKOperation {
        return AKOperation(module: "+", inputs: self, parameter)
    }

    /// Offsetting by way of addition
    ///
    /// - parameter parameter: The amount to offset by
    ///
    public func offsetBy(_ parameter: AKParameter) -> AKOperation {
        return self.plus(parameter)
    }
}

/// Helper function for addition
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func +(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().plus(right)
}

/// Helper function for addition
///
/// - Parameters:
///   - first: 1st parameter
///   - second: 2nd parameter
///
public func +(first: AKStereoOperation, second: AKStereoOperation) -> AKStereoOperation {
    return AKStereoOperation(module: "rot + rot rot +",
                             inputs: first.left(), first.right(), second.left(), second.right())
}
