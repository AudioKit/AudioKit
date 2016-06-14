//
//  reverberateWithCostello.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
    /// modeling scattering junction of 8 lossless waveguides of equal
    /// characteristic impedance.
    ///
    /// - returns: AKStereoOperation
    /// - parameter input: Input audio signal
    /// - parameter feedback: Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. (Default: 0.6, Minimum: 0.0, Maximum: 1.0)
    /// - parameter cutoffFrequency: Low-pass cutoff frequency. (Default: 4000, Minimum: 12.0, Maximum: 20000.0)
     ///
    public func reverberateWithCostello(
        feedback: AKParameter = 0.6,
        cutoffFrequency: AKParameter = 4000
        ) -> AKStereoOperation {
            return AKStereoOperation("(\(self.toStereo()) \(feedback) \(cutoffFrequency) revsc)")
    }
}
