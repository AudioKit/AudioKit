// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// Approximation Operators - for when Swift gets double / float arithmetic wrong

infix operator ~==: ComparisonPrecedence
/// Approximate equality
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side
public func ~== (left: Double, right: Double) -> Bool {
    return fabs(left.distance(to: right)) <= 1e-15
}

infix operator ~!=: ComparisonPrecedence
/// Approximate inequality
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side
public func ~!= (left: Double, right: Double) -> Bool {
    return !(left ~== right)
}

infix operator ~<=: ComparisonPrecedence
/// Approximate less than or equal to
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side
public func ~<= (left: Double, right: Double) -> Bool {
    return (left ~== right) || (left ~< right)
}

infix operator ~>=: ComparisonPrecedence
/// Approximate greater than or equal to
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side
public func ~>= (left: Double, right: Double) -> Bool {
    return (left ~== right) || (left ~> right)
}

infix operator ~<: ComparisonPrecedence
/// Approximate less than
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side
public func ~< (left: Double, right: Double) -> Bool {
    return left.distance(to: right) > 1e-15
}

infix operator ~>: ComparisonPrecedence
/// Approximate greater than
/// - Parameters:
///   - left: Left hand side
///   - right: Right hand side

public func ~> (left: Double, right: Double) -> Bool {
    return left.distance(to: right) < -1e-15
}
