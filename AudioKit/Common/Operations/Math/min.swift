//
//  min.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation


/// Minimum of two operations
///
/// - returns: AKOperation
/// - parameter x: 1st operation
/// - parameter y: 2nd operation
///
public func min(_ x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation("(\(x.toMono()) \(y.toMono()) min)")
}

/// Minimum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter x: parameter
/// - parameter y: operation
///
public func min(_ operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("(\(operation.toMono()) \(parameter) min)")
}

/// Minimum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter x: parameter
/// - parameter y: operation
///
public func min(_ parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return min(operation, parameter)
}
