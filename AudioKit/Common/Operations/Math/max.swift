//
//  max.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Maximum of two operations
///
/// - returns: AKOperation
/// - parameter x: 1st operation
/// - parameter y: 2nd operation
///
public func max(_ x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation("(\(x) \(y) max)")
}

/// Maximum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter operation: operation
/// - parameter parameter: parameter
///
public func max(_ operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("\(operation.toMono()) \(parameter) max ")
}

/// Maximum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter parameter: parameter
/// - parameter operation: operation
///
public func max(_ parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return max(operation.toMono(), parameter)
}

