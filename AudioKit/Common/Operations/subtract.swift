//
//  subtract.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    /** minus: Subtraction of parameters
     - returns: AKParameter
     - parameter subtrahend: The amount to subtract
     */
    public func minus(subtrahend: AKParameter) -> AKParameter {
        return AKParameter("\(self)\(subtrahend)-")
    }
    
    /** minus: Subtraction of parameters
     - returns: AKParameter
     - parameter subtrahend: The amount to subtract
     */
    public func minus(subtrahend: Double) -> AKParameter {
        return AKParameter("\(self)\(subtrahend.ak)-")
    }

}

extension AKP {
    /** subtract: Subtraction of parameters
     - returns: AKParameter
     - Parameter parameter1: The first parameter
     - Parameter parameter2: The second parameter
     */
    public static func subtract(minuend: AKParameter, _ subtrahend: AKParameter) -> AKParameter {
        return minuend.minus(subtrahend)
    }
    
    /** sum: Subtraction of parameters
     - returns: AKParameter
     - Parameter parameter1: The first parameter
     - Parameter parameter2: The second parameter
     */
    public static func difference(minuend: AKParameter, _ subtrahend: AKParameter) -> AKParameter {
        return minuend.minus(subtrahend)
    }
}

/** Helper function for Subtraction
 - returns: AKParameter
 - left: 1st parameter
 - right: 2nd parameter
 */
public func - (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.minus(right)
}

/** Helper function for Subtraction
 - returns: AKParameter
 - left: 1st parameter
 - right: Constant parameter
 */
public func - (left: AKParameter, right: Double) -> AKParameter {
    return left.minus(right)
}

/** Helper function for Subtraction
 - returns: AKParameter
 - left: Constant parameter
 - right: 2nd parameter
 */
public func - (left: Double, right: AKParameter) -> AKParameter {
    return right.minus(left)
}
