//
//  pan.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Panner
    ///
    /// - returns: AKStereoOperation
    /// - parameter input: Input audio signal
    /// - parameter pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center. (Default: 0, Minimum: , Maximum: )
     ///
    public func pan(_ pan: AKParameter = 0) -> AKStereoOperation {
        return AKStereoOperation("(\(self.toMono()) \(pan) pan)")
    }
}
