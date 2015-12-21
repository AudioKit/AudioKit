//
//  min.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


/** Minimum of two operations
 
 - returns: AKOperation
 - parameter x: 1st operation
 - parameter y: 2nd operation
 */
public func min(x: AKOperation, _ y: AKOperation) -> AKOperation {
    return AKOperation("\(x) \(y) min ")
}

/** Minimum of an operation and a parameter
 
 - returns: AKOperation
 - parameter x: parameter
 - parameter y: operation
 */
public func min(operation: AKOperation, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("\(operation) \(parameter) min ")
}

/** Minimum of an operation and a parameter
 
 - returns: AKOperation
 - parameter x: parameter
 - parameter y: operation
 */
public func min(parameter: AKParameter, _ operation: AKOperation) -> AKOperation {
    return min(operation, parameter)
}
