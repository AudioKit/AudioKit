// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// An automatic wah effect, ported from Guitarix via Faust.
    ///
    /// - Parameters:
    ///   - wah: Wah Amount (Default: 0, Minimum: 0, Maximum: 1)
    ///   - amplitude: Overall level (Default: 0.1, Minimum: 0, Maximum: 1)
    ///
    public func autoWah(wah: OperationParameter = 0, amplitude: OperationParameter = 0.1) -> Operation {
        return Operation(module: "100 autowah", inputs: toMono(), amplitude, wah)
    }

    /// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1])
    /// Based on work by Perry Cook.
    ///
    /// - parameter input: Input audio signal
    ///
    public func dcBlock() -> Operation {
        return Operation(module: "dcblk", inputs: toMono())
    }

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 500, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassButterworthFilter(cutoffFrequency: OperationParameter = 500) -> Operation {
        return Operation(module: "buthp", inputs: toMono(), cutoffFrequency)
    }

    /// A complement to the LowPassFilter.
    ///
    /// - parameter halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///                             (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassFilter(halfPowerPoint: OperationParameter = 1_000) -> Operation {
        return Operation(module: "atone", inputs: toMono(), halfPowerPoint)
    }

    /// Analogue model of the Korg 35 Lowpass Filter
    ///
    /// - returns: Operation
    /// - parameter input: Input audio signal
    /// - parameter cutoffFrequency: Filter cutoff (Default: 1000.0, Minimum: 0.0, Maximum: 22050.0)
    /// - parameter resonance: Filter resonance (should be between 0-2) (Default: 1.0, Minimum: 0.0, Maximum: 2.0)
    /// - parameter saturation: Filter saturation. (Default: 0.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public func korgLowPassFilter(cutoffFrequency: OperationParameter = 1_000.0,
                                  resonance: OperationParameter = 1.0,
                                  saturation: OperationParameter = 0.0) -> Operation {
        return Operation(module: "wpkorg35",
                           inputs: toMono(), cutoffFrequency, resonance, saturation)
    }

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func lowPassButterworthFilter(cutoffFrequency: OperationParameter = 1_000) -> Operation {
        return Operation(module: "butlp", inputs: toMono(), cutoffFrequency)
    }

    /// A first-order recursive low-pass filter with variable frequency response.
    ///
    /// - parameter halfPowerPoint: The response curve's half-power point, in Hertz. Half power is defined as
    ///                             peak power / root 2. (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func lowPassFilter(halfPowerPoint: OperationParameter = 1_000) -> Operation {
        return Operation(module: "tone", inputs: toMono(), halfPowerPoint)
    }

    /// A modal resonance filter used for modal synthesis. Plucked and bell sounds
    /// can be created using  passing an impulse through a combination of modal
    /// filters.
    ///
    /// - Parameters:
    ///   - frequency: Resonant frequency of the filter. (Default: 500.0, Minimum: 12.0, Maximum: 20000.0)
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///                    (Default: 50.0, Minimum: 0.0, Maximum: 100.0)
    ///
    public func modalResonanceFilter(frequency: OperationParameter = 500.0,
                                     qualityFactor: OperationParameter = 50.0) -> Operation {
        return Operation(module: "mode", inputs: toMono(), frequency, qualityFactor)
    }

    /// Moog Ladder is an new digital implementation of the Moog ladder filter based
    /// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
    /// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
    /// Napoli). This implementation is probably a more accurate digital
    /// representation of the original analogue filter.
    ///
    /// - Parameters:
    ///   - cutoffFrequency: Filter cutoff frequency. (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause
    ///                aliasing, analogue synths generally allow resonances to be above 1.
    ///                (Default: 0.5, Minimum: 0.0, Maximum: 2.0)
    ///
    public func moogLadderFilter(cutoffFrequency: OperationParameter = 1_000,
                                 resonance: OperationParameter = 0.5) -> Operation {
        return Operation(module: "moogladder",
                           inputs: toMono(), cutoffFrequency, resonance)
    }

    /// A second-order resonant filter.
    ///
    /// - Parameters:
    ///   - frequency: The center frequency of the filter, or frequency position of the peak response
    ///                (defaults to 4000 Hz).
    ///   - bandwidth: The bandwidth of the filter (the Hz difference between the upper and lower half-power points
    ///                (defaults to 1000 Hz).
    ///
    public func resonantFilter(frequency: OperationParameter = 4_000.0,
                               bandwidth: OperationParameter = 1_000.0) -> Operation {
        return Operation(module: "reson", inputs: toMono(), frequency, bandwidth)
    }


    /// A modal resonance filter used for modal synthesis. Plucked and bell sounds
    /// can be created using  passing an impulse through a combination of modal
    /// filters.
    ///
    /// - Parameters:
    ///   - frequency: Fundamental frequency of the filter. (Default: 100.0, Minimum: 12.0, Maximum: 20000.0)
    ///   - feedback: Feedback gain. A value close to 1 creates a slower decay and a more pronounced resonance.
    ///               Small values may leave the input signal unaffected. Depending on the filter frequency,
    ///               typical values are > .9.  Default 0.95
    ///
    public func stringResonator(frequency: OperationParameter = 100.0,
                                feedback: OperationParameter = 0.95) -> Operation {
        return Operation(module: "streson", inputs: toMono(), frequency, feedback)
    }

    /// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion
    ///                 controlled by the filter parameters, in such a way that both low cutoff and high resonance
    ///                 increase the distortion amount. (Default: 0.5, Minimum: 0.0, Maximum: 2.0)
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz. (Default: 1500, Minimum: 12.0, Maximum: 20000.0)
    ///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff
    ///                frequency. Values slightly greater than 1 are possible for more sustained oscillation and an
    ///                “overdrive” effect. (Default: 0.5, Minimum: 0.0, Maximum: 2.0)
    ///
    public func threePoleLowPassFilter(distortion: OperationParameter = 0.5,
                                       cutoffFrequency: OperationParameter = 1_500,
                                       resonance: OperationParameter = 0.5) -> Operation {
        return Operation(module: "lpf18", inputs: toMono(), distortion, cutoffFrequency, resonance)
    }
}
