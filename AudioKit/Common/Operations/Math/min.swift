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
 - parameter left: 1st operation
 - parameter right: 2nd operation
 */
public func min(left: AKOperation, _ right: AKOperation) -> AKOperation {
    return AKOperation("\(left)\(right)min")
}

/** Minimum of two operations
 
 - returns: AKOperation
 - parameter left: Constant Value
 - parameter right: Operation
 */
public func min(left: Double, _ right: AKOperation) -> AKOperation {
    return min(left.ak, right)
}

/** Minimum of two operations
 
 - returns: AKOperation
 - parameter left: Operation
 - parameter right: Constant value
 */
public func min(left: AKOperation, _ right: Double) -> AKOperation {
    return min(left, right.ak)
}
