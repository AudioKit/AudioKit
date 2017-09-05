//
//  reverberateWithFlatFrequencyResponse.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKComputedParameter {

    /// This filter reiterates the input with an echo density determined by loop
    /// time. The attenuation rate is independent and is determined by the
    /// reverberation time (defined as the time in seconds for a signal to decay to
    /// 1/1000, or 60dB down from its original amplitude).  Output will begin to
    /// appear immediately.
    ///
    /// - Parameters:
    ///   - reverbDuration: The duration in seconds for a signal to decay to 1/1000, or 60dB down from 
    ///                     its original amplitude. (Default: 0.5, Minimum: 0, Maximum: 10)
    ///   - loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the delay time or 
    ///                   “echo density” of the reverberation. (Default: 0.1, Minimum: 0, Maximum: 1)
    ///
    public func reverberateWithFlatFrequencyResponse(
        reverbDuration: AKParameter = 0.5,
        loopDuration: Double = 0.1
        ) -> AKOperation {
        return AKOperation(module: "allpass", inputs: toMono(), reverbDuration, loopDuration)
    }
}
