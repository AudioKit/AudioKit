//
//  AKComputedParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// A computed parameter differs from a regular parameter in that it only exists within an operation (unlike float, doubles, and ints which have a value outside of an operation)
public protocol AKComputedParameter: AKParameter {}

/// An AKOperation is a computed parameter that can be passed to other operations in the same operation node
public struct AKOperation: AKComputedParameter {

    /// Default input to any operation
    public static var input = AKOperation("(14 p)")
    
    /// Left input to any stereo operation
    public static var leftInput = AKOperation("(14 p)")

    /// Right input to any stereo operation
    public static var rightInput = AKOperation("(15 p)")
    
    /// Dummy trigger
    public static var trigger = AKOperation("(0 p)")

    /// Call up a numbered parameter to the internal operation
    ///
    /// - parameter i: Number of the parameter to recall
    ///
    public static func parameters(i: Int) -> AKOperation {
        return AKOperation("(\(i) p)")
    }

    /// Performs absolute value on the operation
    public func abs() -> AKOperation {
        return AKOperation("(\(self) abs)")
    }

    /// Performs floor calculation on the operation
    public func floor() -> AKOperation {
        return AKOperation("(\(self) floor)")
    }

    /// Returns the fractional part of the operation (as opposed to the integer part)
    public func fract() -> AKOperation {
        return AKOperation("(\(self) frac)")
    }

    /// Performs natural logarithm on the operation
    public func log() -> AKOperation {
        return AKOperation("(\(self) log)")
    }

    /// Performs Base 10 logarithm on the operation
    public func log10() -> AKOperation {
        return AKOperation("(\(self) log10)")
    }

    /// Rounds the operation to the nearest integer
    public func round() -> AKOperation {
        return AKOperation("(\(self) round)")
    }

    /// Returns a frequency for a given midi note number
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation("(\(self) mtof)")
    }

    /// Sporth representation of the operation
    var operationString = ""

    /// Redefining description to return the operation string
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }

    /// Initialize the operation as a constant value
    ///
    /// - parameter value: Constant value as an operation
    ///
    public init(_ value: Double) {
        self.operationString = "\(value)"
    }

    /// Initialize the operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.operationString = operationString
    }
}

/// Performs absolute value on the operation
///
/// - parameter parameter: AKComputedParameter to operate on
///
public func abs(parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func floor(operation: AKOperation) -> AKOperation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - parameter operation: AKComputedParameter to operate on
///
public func fract(operation: AKOperation) -> AKOperation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func log(operation: AKOperation) -> AKOperation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - parmeter operation: AKComputedParameter to operate on
///
public func log10(operation: AKOperation) -> AKOperation {
    return operation.log10()

}

/// Rounds the operation to the nearest integer
///
/// - parameterd operation: AKComputedParameter to operate on
///
public func round(operation: AKOperation) -> AKOperation {
    return operation.round()
}
