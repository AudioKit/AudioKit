//
//  trackedAmplitude.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {
    
    /// Panner
    ///
    /// - parameter input: Input audio signal
    ///
    public func trackedAmplitude(trackedAmplitude: AKParameter = 0) -> AKOperation {
        return AKOperation(module: "rms", inputs: self.toMono())
    }
}
