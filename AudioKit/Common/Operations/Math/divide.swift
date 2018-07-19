//
//  divide.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKOperation {
    /// Division of parameters
    ///
    /// - parameter denominator: The amount to divide
    ///
    public func dividedBy(_ denominator: AKParameter) -> AKOperation {
        return AKOperation(module: "/", inputs: self, denominator)
    }
}

/// Helper function for Division
///
/// - Parameters:
///   - numerator: Mono parameter
///   - denominator: The amount to divide
///
public func / (numerator: AKParameter, denominator: AKParameter) -> AKOperation {
    return numerator.toMono().dividedBy(denominator)
}

/// Helper function for Division
///
/// - Parameters:
///   - numerator: Stereo operation
///   - denominator: The amount to divide
///
public func / (numerator: AKStereoOperation, denominator: AKParameter) -> AKStereoOperation {
    return AKStereoOperation(module: "dup rot swap / rot rot / swap", inputs: numerator, denominator)
}
