//
//  add.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** plus: Addition/Summation of parameters
     - returns: AKOperation
     - parameter parameter: The amount to add
     */
    public func plus(parameter: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(parameter)+")
    }
    
    /** plus: Addition/Summation of parameters
     - returns: AKOperation
     - parameter parameter: The amount to add
     */
    public func plus(parameter: Double) -> AKOperation {
        return AKOperation("\(self)\(parameter.ak)+")
    }
    
    /** offsetBy: Offsetting by way of addition
     - returns: AKOperation
     - parameter parameter: The amount to offset by
     */
    public func offsetBy(parameter: AKOperation) -> AKOperation {
        return self.plus(parameter)
    }
    /** offsetBy: Offsetting by way of addition
     - returns: AKOperation
     - parameter parameter: The amount to offset by
     */
    public func offsetBy(parameter: Double) -> AKOperation {
        return self.plus(parameter.ak)
    }
}

/** Helper function for addition
- returns: AKOperation
- left: 1st parameter
- right: 2nd parameter
*/
public func + (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.plus(right)
}

/** Helper function for addition
 - returns: AKOperation
 - left: 1st parameter
 - right: Constant parameter
 */
public func + (left: AKOperation, right: Double) -> AKOperation {
    return left.plus(right)
}

/** Helper function for addition
 - returns: AKOperation
 - left: Constant parameter
 - right: 2nd parameter
 */
public func + (left: Double, right: AKOperation) -> AKOperation {
    return right.plus(left)
}
