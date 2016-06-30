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
/// - Parameters:
///   - x: 1st operation
///   - y: 2nd operation
///
public func max(x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation("(\(x) \(y) max)")
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - operation: operation
///   - parameter: parameter
///
public func max(operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("\(operation.toMono()) \(parameter) max ")
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - parameter: parameter
///   - operation: operation
///
public func max(parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return max(operation.toMono(), parameter)
}

