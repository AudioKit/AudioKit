//
//  max.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Maximum of two operations

 - returns: AKOperation
 - parameter x: 1st operation
 - parameter y: 2nd operation
 */
public func max(x: AKOperation, _ y: AKOperation) -> AKOperation {
    return AKOperation("\(x) \(y) max ")
}

/** Maximum of an operation and a parameter
 
 - returns: AKOperation
 - parameter x: parameter
 - parameter y: operation
 */
public func max(operation: AKOperation, _ parameter: AKParameter) -> AKOperation {
    return AKOperation("\(operation) \(parameter) max ")
}

/** Maximum of an operation and a parameter
 
 - returns: AKOperation
 - parameter x: parameter
 - parameter y: operation
 */
public func max(parameter: AKParameter, _ operation: AKOperation) -> AKOperation {
    return max(operation, parameter)
}

