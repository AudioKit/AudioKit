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
/// - Parameters:
///   - x: 1st operation
///   - y: 2nd operation
///
public func min(_ x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation(module: "min", inputs: x.toMono(), y.toMono())
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation(module: "min", inputs: operation.toMono(), parameter)
}

/// Minimum of an operation and a parameter
///
/// - Parameters:
///   - x: parameter
///   - y: operation
///
public func min(_ parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return min(operation, parameter)
}
