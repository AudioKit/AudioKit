//
//  clip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Clips a signal to a predefined limit, in a "soft" manner, using one of three
    /// methods.
    ///
    /// - returns: AKComputedParameter
    /// - parameter input: Input audio signal
    /// - parameter limit: Threshold / limiting value. (Default: 1.0, Minimum: 0.0, Maximum: 1.0)
     ///
    public func clip(_ limit: AKParameter = 1.0) -> AKOperation {
            return AKOperation("(\(self.toMono()) \(limit) clip)")
    }
}
