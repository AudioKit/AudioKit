//
//  multiply.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    /** times: Multiplication of parameters
     - returns: AKParameter
     - parameter parameter: The amount to multiply
     */
    public func times(parameter: AKParameter) -> AKParameter {
        return AKParameter("\(self)\(parameter)*")
    }
    
    /** times: Multiplication of parameters
     - returns: AKParameter
     - parameter parameter: The amount to multiply
     */
    public func times(parameter: Float) -> AKParameter {
        return AKParameter("\(self)\(parameter.ak)*")
    }
    
    /** scaledBy: Offsetting by way of multiplication
     - returns: AKParameter
     - parameter parameter: The amount to scale by
     */
    public func scaledBy(parameter: AKParameter) -> AKParameter {
        return self.times(parameter)
    }
    /** scaledBy: Offsetting by way of multiplication
     - returns: AKParameter
     - parameter parameter: The amount to scale by
     */
    public func scaledBy(parameter: Float) -> AKParameter {
        return self.times(parameter.ak)
    }
}

extension AKP {
    /** product: Multiplication of parameters
     - returns: AKParameter
     - Parameter parameter1: The first parameter
     - Parameter parameter2: The second parameter
     */
    public static func product(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
        return parameter1.times(parameter2)
    }
}

/** Helper function for Multiplication
 - returns: AKParameter
 - left: 1st parameter
 - right: 2nd parameter
 */
public func * (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.times(right)
}

/** Helper function for Multiplication
 - returns: AKParameter
 - left: 1st parameter
 - right: Constant parameter
 */
public func * (left: AKParameter, right: Float) -> AKParameter {
    return left.times(right)
}

/** Helper function for Multiplication
 - returns: AKParameter
 - left: Constant parameter
 - right: 2nd parameter
 */
public func * (left: Float, right: AKParameter) -> AKParameter {
    return right.times(left)
}
