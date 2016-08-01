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
    /// - Parameters:
    ///   - wah: Wah Amount (Default: 0, Minimum: 0, Maximum: 1)
    ///   - amplitude: Overall level (Default: 0.1, Minimum: 0, Maximum: 1)
    ///
    public func autoWah(
        wah wah: AKParameter = 0,
        amplitude: AKParameter = 0.1
        ) -> AKOperation {
        return AKOperation(module: "100 autowah",
                           inputs: self.toMono(), amplitude, wah)
    }
}
