//
//  add.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Addition/Summation of operations
    ///
    ///  - returns: AKOperation
    ///  - parameter parameter: The amount to add
    public func plus(_ parameter: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(parameter) +)")
    }
    
    /// Offsetting by way of addition
    ///
    /// - returns: AKOperation
    /// - parameter parameter: The amount to offset by
    public func offsetBy(_ parameter: AKParameter) -> AKOperation {
        return self.plus(parameter)
    }
}

/// Helper function for addition
///
/// - returns: AKOperation
/// - left: 1st parameter
/// - right: 2nd parameter
public func +(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().plus(right)
}
