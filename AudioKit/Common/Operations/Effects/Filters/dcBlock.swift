//
//  dcBlock.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1])
    /// Based on work by Perry Cook.
    ///
    /// - parameter input: Input audio signal
    ///
    public func dcBlock() -> AKOperation {
        return AKOperation(module: "dcblock", inputs: self.toMono())
    }
}
