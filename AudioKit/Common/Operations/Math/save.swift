//
//  save.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKOperation {

    /// Save a value into the parameters array for using outside of the operation
    ///
    /// - parameter parameterIndex: Location in the parameters array to save this value
    ///
    public func save(parameterIndex: Int) -> AKOperation {
        return AKOperation(module: "dup \(parameterIndex) pset", inputs: toMono())
    }
}
