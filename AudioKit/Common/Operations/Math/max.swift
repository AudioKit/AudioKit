//
//  max.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// Maximum of two operations
///
/// - returns: AKOperation
/// - parameter x: 1st operation
/// - parameter y: 2nd operation
///
public func max(x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation("(\(x) \(y) max)")
}

/// Maximum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter operation: operation
/// - parameter parameter: parameter
///
public func max(operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("\(operation.toMono()) \(parameter) max ")
}

/// Maximum of an operation and a parameter
///
/// - returns: AKOperation
/// - parameter parameter: parameter
/// - parameter operation: operation
///
public func max(parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return max(operation.toMono(), parameter)
}

