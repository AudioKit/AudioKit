//
//  divide.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Division of parameters
    ///
    /// - returns: AKOperation
    /// - parameter parameter: The amount to divide
    ///
    public func dividedBy(_ parameter: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(parameter) /)")
    }
}

/// Helper function for Division
///
/// - returns: AKOperation
/// - parameter left: 1st parameter
/// - parameter right: 2nd parameter
///
public func /(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().dividedBy(right)
}

