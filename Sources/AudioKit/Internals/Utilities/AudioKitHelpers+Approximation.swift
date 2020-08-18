// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// Approximation Operators - for when Swift gets double / float arithmetic wrong
infix operator ~== : ComparisonPrecedence
public func ~== (left: Double, right: Double) -> Bool {
    return fabs(left.distance(to: right)) <= 1e-15
}
infix operator ~!= : ComparisonPrecedence
public func ~!= (left: Double, right: Double) -> Bool {
    return !(left ~== right)
}
infix operator ~<= : ComparisonPrecedence
public func ~<= (left: Double, right: Double) -> Bool {
    return (left ~== right) || (left ~< right)
}
infix operator ~>= : ComparisonPrecedence
public func ~>= (left: Double, right: Double) -> Bool {
    return (left ~== right) || (left ~> right)
}
infix operator ~< : ComparisonPrecedence
public func ~< (left: Double, right: Double) -> Bool {
    return left.distance(to: right) > 1e-15
}
infix operator ~> : ComparisonPrecedence
public func ~> (left: Double, right: Double) -> Bool {
    return left.distance(to: right) < -1e-15
}
