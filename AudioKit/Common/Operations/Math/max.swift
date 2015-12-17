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
 - left: 1st parameter
 - right: 2nd parameter
 */
public func max(left: AKOperation, _ right: AKOperation) -> AKOperation {
    return AKOperation("\(left)\(right)max")
}

/** Maximum of two operations
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func max(left: Double, _ right: AKOperation) -> AKOperation {
    return max(left.ak, right)
}

/** Maximum of two operations
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func max(left: AKOperation, _ right: Double) -> AKOperation {
    return max(left, right.ak)
}
