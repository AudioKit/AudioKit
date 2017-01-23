//
//  save.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /// Save a value into the parameters array for using outside of the operation
    ///
    /// - parameter parameterIndex: Location in the parameters array to save this value
    ///
    public func save(parameterIndex: Int) -> AKOperation {
        return AKOperation(module: "dup \(parameterIndex) pset", inputs: toMono())
    }
}
