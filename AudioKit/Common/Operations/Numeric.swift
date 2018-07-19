//
//  Numeric.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// MARK: Numeric Protocol

/// Very simple protoocol for anything with an instrinsic floating point value.
/// Allows constants to be passed into an AudioKit operation as well as other operations.
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
//public func ==(lhs: Numeric, rhs: Numeric) -> Bool {
//    return lhs.value() == rhs.value()
//}

/// Addition
public func + (lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() + rhs.value()
}

/// Subtraction
public func - (lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() - rhs.value()
}

/// Division
public func / (lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() / rhs.value()
}

/// Multiplication
public func * (lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() * rhs.value()
}
