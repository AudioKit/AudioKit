// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// This is was built using the JC reverb implentation found in FAUST. According
    /// to the source code, the specifications for this implementation were found on
    /// an old SAIL DART backup tape.
    /// This class is derived from the CLM JCRev function, which is based on the use
    /// of networks of simple allpass and comb delay filters.  This class implements
    /// three series allpass units, followed by four parallel comb filters, and two
    /// decorrelation delay lines in parallel at the output.
    ///
    public func reverberateWithChowning() -> AKOperation {
        return AKOperation(module: "jcrev", inputs: toMono())
    }
}
