//
//  Numeric.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

// MARK: Numeric Protocol

///  Helps with casting Int, Float, Double to angles and us repeating ourselves
///  when making arithmetic operators.
public protocol Numeric: AKParameter {
    /// Raw value of the numeric parameter
    func value() -> Double
}

/// Numeric extension for integers
extension Int: Numeric {
    /// Get basic value as a double
    public func value() -> Double {
        return Double(self)
    }
}

/// Numeric extension for floats
extension Float: Numeric {
    /// Get basic value as a double
    public func value() -> Double {
        return Double(self)
    }
}

/// Numeric extension for doubles
extension Double: Numeric {
    /// Get basic value as a double
    public func value() -> Double {
        return Double(self)
    }
}

/// Equality
public func ==(lhs: Numeric, rhs: Numeric) -> Bool {
    return lhs.value() == rhs.value()
}

/// Addition
public func +(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() + rhs.value()
}

/// Subtraction
public func -(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() - rhs.value()
}

/// Division
public func /(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() / rhs.value()
}

/// Multiplication
public func *(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() * rhs.value()
}