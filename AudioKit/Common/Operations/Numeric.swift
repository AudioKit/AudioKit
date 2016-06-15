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

extension Int: Numeric {
    public func value() -> Double {
        return Double(self)
    }
}

extension Float: Numeric {
    public func value() -> Double {
        return Double(self)
    }
}

extension Double: Numeric {
    public func value() -> Double {
        return Double(self)
    }
}

public func ==(lhs: Numeric, rhs: Numeric) -> Bool {
    return lhs.value() == rhs.value()
}

public func +(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() + rhs.value()
}

public func -(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() - rhs.value()
}

public func /(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() / rhs.value()
}

public func *(lhs: Numeric, rhs: Numeric) -> Double {
    return lhs.value() * rhs.value()
}