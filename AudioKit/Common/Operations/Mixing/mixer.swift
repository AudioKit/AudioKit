//
//  mixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Mix together two parameters
///
/// - Parameters:
///   - first: First parameter
///   - second: Second parameter
///   - balance: Value from zero to one indicating balance between first (0) and second (1) (Default: 0.5)
///
public func mixer(first: AKParameter, _ second: AKParameter, balance: AKParameter = 0.5) -> AKOperation {
    return AKOperation(module: "1 swap - cf", inputs: first, second, balance)
}