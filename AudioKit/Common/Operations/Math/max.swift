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
public func max(_ x: AKComputedParameter, _ y: AKComputedParameter) -> AKOperation {
    return AKOperation(module: "max", inputs: x, y)
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - operation: operation
///   - parameter: parameter
///
public func max(_ operation: AKComputedParameter, _ parameter: AKParameter) -> AKOperation {
    return AKOperation(module: "max", inputs: operation.toMono(), parameter)
}

/// Maximum of an operation and a parameter
///
/// - Parameters:
///   - parameter: parameter
///   - operation: operation
///
public func max(_ parameter: AKParameter, _ operation: AKComputedParameter) -> AKOperation {
    return max(operation.toMono(), parameter)
}

