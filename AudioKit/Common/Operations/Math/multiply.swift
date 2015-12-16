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
    public func scaledBy(parameter: Double) -> AKParameter {
        return self.times(parameter.ak)
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
public func * (left: AKParameter, right: Double) -> AKParameter {
    return left.times(right.ak)
}

/** Helper function for Multiplication
 - returns: AKParameter
 - left: Constant parameter
 - right: 2nd parameter
 */
public func * (left: Double, right: AKParameter) -> AKParameter {
    return right.times(left.ak)
}
