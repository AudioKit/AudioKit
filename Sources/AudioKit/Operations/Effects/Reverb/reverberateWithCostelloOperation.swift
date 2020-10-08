// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

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
    public func reverberateWithCostello(
        feedback: OperationParameter = 0.6,
        cutoffFrequency: OperationParameter = 4_000
        ) -> StereoOperation {
        return StereoOperation(module: "revsc",
                                 inputs: self.toStereo(), feedback, cutoffFrequency)
    }
}
