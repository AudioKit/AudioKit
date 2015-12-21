//
//  min.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


/** Minimum of two parameters

 - returns: AKOperation
 - parameter left: 1st parameter
 - parameter right: 2nd parameter
 */
public func min(left: AKParameter, _ right: AKParameter) -> AKOperation {
    return AKOperation("\(left) \(right) min ")
}

/** Minimum of two parameters

 - returns: AKOperation
 - parameter left: Constant Value
 - parameter right: Operation
 */
public func min(left: Double, _ right: AKParameter) -> AKOperation {
    return min(left, right)
}

/** Minimum of two parameters

 - returns: AKOperation
 - parameter left: Operation
 - parameter right: Constant value
 */
public func min(left: AKParameter, _ right: Double) -> AKOperation {
    return min(left, right)
}
