// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension AKTable {

    /// This method will start at rootFrequency * octave, walk up by octaveStepSize, and halt before reaching nyquist.
    /// This method outputs an array where each entry is a tuple of frequency and the maximum number of harmonics.
    /// This method is "pitch"-based, which is not the only way to distribute harmonics.
    ///
    /// Parameters:
    ///   - rootFrequency: the lowest frequency wavetable.  8.17579891564375 corresponds to C0, or nn = 0
    ///   - octaveStepSize: fractions of an octave (i.e., 1).
    ///
    /// Example Output:
    /// [(8.1787833827893177, 2696),
    /// (16.357566765578635, 1348),
    /// (32.715133531157271, 674),
    /// (65.430267062314542, 337),
    /// (131.25, 168),
    /// (262.5, 84),
    /// (525.0, 42),
    /// (1050.0, 21),
    /// (2205.0, 10),
    /// (4410.0, 5),
    /// (11025.0, 2), (22050.0, 1)]

    public class func harmonicPitchRange(rootFrequency: Double = 8.175_798_915_643_75,
                                         octaveStepSize: Double = 1) -> [(Double, Int)] {
        let nyquist = 22_050.0
        var octave = 0.0
        var retVal = [(Double, Int)]()
        while rootFrequency * pow(2, octave) < nyquist {
            var harmonic = 1
            var maxHarmonic = 1
            var frequency = rootFrequency * pow(2, octave)
            octave += octaveStepSize
            while Double(harmonic) * frequency < nyquist {
                maxHarmonic = harmonic
                harmonic += 1
            }
            frequency = nyquist / Double(maxHarmonic)
            if maxHarmonic == 1 {
                if let lastVal = retVal.last {
                    // don't append duplicates
                    if lastVal.1 == maxHarmonic {
                        continue
                    }
                }
            }
            retVal.append((frequency, maxHarmonic))
        }
        return retVal
    }

    /// This method will start at rootFrequency * octave, walk up by octaveStepSize, and halt before reaching nyquist.
    /// This method outputs an array where each entry is a tuple of frequency and the maximum number of harmonics.
    /// This method is "pitch"-based, which may not be the best way to distribute harmonics.
    ///
    /// The design is to create wavetables with the most harmonics for frequencies LESS THAN the frequency of the table.
    /// ASSUME a nyquist 1 harmonic table.  Allows the harmonic distribution to not consider the outlier.

    /// Parameters:
    ///   - f0: the lowest frequency wavetable.  130.8127826503 corresponds to C-1, or nn = 48
    ///   - f1: the highest frequency wavetable.  2093.0045224048 corresponds to C6, or nn = 96
    ///
    ///   - wavetableCount: The number of wavetables from which to interpolate from f0 to f1
    ///
    public class func harmonicFrequencyRange(f0: Double = 130.812_782_650_3,
                                             f1: Double = 2_093.004_522_404_8,
                                             wavetableCount: Int = 12) -> [(Double, Int)] {
        let nyquist = 22_050.0
        var retVal = [(Double, Int)]()
        for i in 0..<wavetableCount {
            var harmonic = 1
            var maxHarmonic = 1
            var frequency = f0 + (f1 - f0) * Double(i) / Double(wavetableCount - 1)
            while Double(harmonic) * frequency < nyquist {
                maxHarmonic = harmonic
                harmonic += 1
            }
            frequency = nyquist / Double(maxHarmonic)
            if maxHarmonic == 1 {
                if let lastVal = retVal.last {
                    // don't append duplicates
                    if lastVal.1 == maxHarmonic {
                        continue
                    }
                }
            }
            retVal.append((frequency, maxHarmonic))
        }
        return retVal
    }

    /// Set table values to sum of sines approximating a sawtooth with harmonicCount harmonics.
    /// Parameters:
    ///   - harmonicCount: the number of harmonics to synthesize
    ///   - clear: will clear the table first
    public func sawtooth(harmonicCount: Int = 1_024, clear: Bool = true) {
        self.phase = 0

        if clear {
            for i in indices {
                self[i] = 0
            }
        }

        let coefficient = {(harmonic: Int) -> Float in
            return 1 / Float(harmonic)
        }

        for h in 1...harmonicCount {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    /// Set table values to sum of sines approximating a square with harmonicCount harmonics.
    /// Parameters:
    ///   - harmonicCount: the number of harmonics to synthesize
    ///   - clear: will clear the table first
    public func square(harmonicCount: Int = 1_024, clear: Bool = true) {
        self.phase = 0

        if clear {
            for i in indices {
                self[i] = 0
            }
        }

        let coefficient = {(harmonic: Int) -> Float in
            return Float(harmonic % 2) / Float(harmonic)
        }

        for h in 1...harmonicCount {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    /// Set table values to sum of sines approximating a triangle with harmonicCount harmonics.
    /// Parameters:
    ///   - harmonicCount: the number of harmonics to synthesize
    ///   - clear: will clear the table first
    public func triangle(harmonicCount: Int = 1_024, clear: Bool = true) {
        self.phase = 0

        if clear {
            for i in indices {
                self[i] = 0
            }
        }

        let coefficient = {(harmonic: Int) -> Float in
            var c: Float = 0
            let i = harmonic - 1
            let m2 = i % 2
            let m4 = i % 4
            if m4 == 0 {
                c = 1
            } else if m2 == 0 {
                c = -1
            }

            return c / Float(harmonic * harmonic)
        }

        for h in 1...harmonicCount {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.141_592_65 * Float(i + phaseOffset) / Float(count) ) )
            }
        }
    }

    /// Set table values to sum of sines approximating a pulse width of period with harmonicCount harmonics.
    /// Due to DC component, and scaling/normalizing, a "clear" parameter is not provided.
    /// Parameters:
    ///   - harmonicCount: the number of harmonics to synthesize
    ///   - period: float on (0,1) for the range above 0
    public func pwm(harmonicCount: Int = 1_024, period: Float = 1 / 8) {
        self.phase = 0

        let t: Float = 1
        let k: Float = period
        let d: Float = k / t
        let a: Float = 1
        let a0: Float = a * d

        for i in indices {
            self[i] = a0
        }

        let coefficient = {(harmonic: Int) -> Float in
            let c: Float = ((2.0 * a) / (Float(harmonic) * 3.141_592_65)) * sin( Float(Float(harmonic) * 3.141_592_65 * d) )
            return c
        }

        // offset the samples by 1/2 period
        let sampleOffset = Int(period * Float(count) * 0.5)

        for h in 1...harmonicCount {
            for i in indices {
                let x = Float(coefficient(h) * cos(Float(h) * 2.0 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
                let index = (i + sampleOffset) % count
                self[index] += x
            }
        }

        // finally, convert [0,1] to [-1,1]
        for i in indices {
            self[i] *= 2
            self[i] -= 1
        }
    }

    /// returns a tuple with min, max, absMax
    public func minMax() -> (min: Float, max: Float, absMax: Float) {
        var min: Float = 999_999
        var max: Float = -999_999
        var absMax: Float = -1

        for i in indices {
            let v = self[i]
            if v < min {
                min = v
            }
            if v > max {
                max = v
            }
            if abs(v) > absMax {
                absMax = abs(v)
            }
        }
        return (min, max, absMax)
    }

    /// In-place normalize
    public func normalize() {
        let mma = self.minMax()
        let absMax = mma.2
        if absMax > 0.000_001 {
            for i in indices {
                self[i] /= absMax
            }
            AKLog("absMax = \(absMax): NOW NORMALIZED")
        } else {
            AKLog("absMax = \(absMax): NOT NORMALIZED")
        }
    }

    /// In-place reverse samples
    public func reverse() {
        for i in 0..<indices.count / 2 {
            let j = indices.count - 1 - i
            let tmp = self[i]
            self[i] = self[j]
            self[j] = tmp
        }
    }

    /// In-place invert samples
    public func invert() {
        for i in indices {
            self[i] = -self[i]
        }
    }

    /// compare self with t, return mean-squared distance.
    public func msd(t: AKTable) -> Element {
        var msd: Element = 0
        for i in indices {
            var d: Element = self[i] - t[i]
            d *= d
            msd += d
        }
        msd = sqrt(msd) / Element(indices.count)

        return msd
    }
}
