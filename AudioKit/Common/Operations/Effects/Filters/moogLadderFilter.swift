//
//  moogLadderFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Moog Ladder is an new digital implementation of the Moog ladder filter based
    /// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
    /// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
    /// Napoli). This implementation is probably a more accurate digital
    /// representation of the original analogue filter.
    ///
    /// - Parameters:
    ///   - cutoffFrequency: Filter cutoff frequency. (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1. (Default: 0.5, Minimum: 0.0, Maximum: 2.0)
    ///
    public func moogLadderFilter(
        cutoffFrequency: AKParameter = 1_000,
        resonance: AKParameter = 0.5
        ) -> AKOperation {
        return AKOperation(module: "moogladder",
                           inputs: toMono(), cutoffFrequency, resonance)
    }
}
