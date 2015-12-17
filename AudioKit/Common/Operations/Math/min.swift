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
 - left: 1st parameter
 - right: 2nd parameter
 */
public func min(left: AKOperation, _ right: AKOperation) -> AKOperation {
    return AKOperation("\(left)\(right)min")
}

/** Minimum of two operations
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func min(left: Double, _ right: AKOperation) -> AKOperation {
    return min(left.ak, right)
}

/** Minimum of two operations
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func min(left: AKOperation, _ right: Double) -> AKOperation {
    return min(left, right.ak)
}
