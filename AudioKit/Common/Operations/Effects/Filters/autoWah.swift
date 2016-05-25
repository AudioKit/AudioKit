//
//  autoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// An automatic wah effect, ported from Guitarix via Faust.
    ///
    /// - returns: AKComputedParameter
    /// - parameter input: Input audio signal
    /// - parameter wah: Wah Amount (Default: 0, Minimum: 0, Maximum: 1)
    /// - parameter mix: Dry/Wet Mix (Default: 1, Minimum: 0, Maximum: 1)
    /// - parameter amplitude: Overall level (Default: 0.1, Minimum: 0, Maximum: 1)
     ///
    public func autoWah(
        wah wah: AKParameter = 0,
        mix: AKParameter = 1,
        amplitude: AKParameter = 0.1
        ) -> AKOperation {
            return AKOperation("(\(self.toMono()) \(amplitude) \(wah) \(100.0 * mix) autowah)")
    }
}
