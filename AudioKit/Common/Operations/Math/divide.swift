//
//  divide.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /// Division of parameters
    ///
    /// - parameter parameter: The amount to divide
    ///
    public func dividedBy(parameter: AKParameter) -> AKOperation {
        return AKOperation(module: "/", inputs: self, parameter)
    }
}

/// Helper function for Division
///
/// - Parameters:
///   - left: 1st parameter
///   - right: 2nd parameter
///
public func /(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.toMono().dividedBy(right)
}

/// Helper function for Division
///
/// - Parameters:
///   - left: stereo operation
///   - right: parameter
///
public func /(left: AKStereoOperation, right: AKParameter) -> AKStereoOperation {
    return AKStereoOperation(module: "dup rot swap / rot rot / swap", inputs: left, right)
}
