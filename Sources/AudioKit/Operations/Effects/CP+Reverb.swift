// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// This is was built using the JC reverb implentation found in FAUST. According
    /// to the source code, the specifications for this implementation were found on
    /// an old SAIL DART backup tape.
    /// This class is derived from the CLM JCRev function, which is based on the use
    /// of networks of simple allpass and comb delay filters.  This class implements
    /// three series allpass units, followed by four parallel comb filters, and two
    /// decorrelation delay lines in parallel at the output.
    ///
    public func reverberateWithChowning() -> Operation {
        return Operation(module: "jcrev", inputs: toMono())
    }
    
    /// This filter reiterates input with an echo density determined by
    /// loopDuration. The attenuation rate is independent and is determined by
    /// reverbDuration, the reverberation duration (defined as the time in seconds
    /// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
    /// Output from a comb filter will appear only after loopDuration seconds.
    ///
    /// - Parameters:
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original
    ///                     amplitude. (aka RT-60). (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time.
    ///                   Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly
    ///                   between 0 and sr/2. (Default: 0.1, Minimum: 0.0, Maximum: 1.0)
    ///
    public func reverberateWithCombFilter(reverbDuration: OperationParameter = 1.0,
                                          loopDuration: OperationParameter = 0.1) -> Operation {
        return Operation(module: "comb", inputs: toMono(), reverbDuration, loopDuration)
    }
    
    /// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
    /// modeling scattering junction of 8 lossless waveguides of equal
    /// characteristic impedance.
    ///
    /// - Parameters:
    ///   - feedback: Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall,
    ///               and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make
    ///               the opcode unstable. (Default: 0.6, Minimum: 0.0, Maximum: 1.0)
    ///   - cutoffFrequency: Low-pass cutoff frequency. (Default: 4000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func reverberateWithCostello(feedback: OperationParameter = 0.6,
                                        cutoffFrequency: OperationParameter = 4_000) -> StereoOperation {
        return StereoOperation(module: "revsc",
                               inputs: self.toStereo(), feedback, cutoffFrequency)
    }
    
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
    public func reverberateWithFlatFrequencyResponse(reverbDuration: OperationParameter = 0.5,
                                                     loopDuration: Double = 0.1) -> Operation {
        return Operation(module: "allpass", inputs: toMono(), reverbDuration, loopDuration)
    }
}
