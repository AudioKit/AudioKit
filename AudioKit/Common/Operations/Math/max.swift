//
//  max.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


/** Maximum of two parameters

 - returns: AKOperation
 - parameter left: 1st parameter
 - parameter right: 2nd parameter
 */
public func max(left: AKParameter, _ right: AKParameter) -> AKOperation {
    return AKOperation("\(left) \(right) max ")
}

/** Maximum of two parameters

 - returns: AKOperation
 - parameter left: Constant Value
 - parameter right: Operation
 */
public func max(left: Double, _ right: AKParameter) -> AKOperation {
    return max(left, right)
}

/** Maximum of two parameters

 - returns: AKOperation
 - parameter left: Operation
 - parameter right: Constant Value
 */
public func max(left: AKParameter, _ right: Double) -> AKOperation {
    return max(left, right)
}
