//
//  AKTable+AdditiveSynthesis.swift
//
//  Created by Marcus W. Hobbs on 7/23/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

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
    /// Example Output: [(8.1757989156437496, 2696), (16.351597831287499, 1348), (32.703195662574998, 674), (65.406391325149997, 337), (130.81278265029999, 168), (261.62556530059999, 84), (523.25113060119997, 42), (1046.5022612023999, 21), (2093.0045224047999, 10), (4186.0090448095998, 5), (8372.0180896191996, 2), (16744.036179238399, 1)]
    public class func harmonicPitchRange(rootFrequency: Double = 8.17579891564375, octaveStepSize: Double = 1) -> [(Double, Int)] {
        let nyquist = 22_050.0
        var octave = 0.0
        var retVal = [(Double, Int)]()
        while rootFrequency * pow(2, octave) < nyquist {
            var harmonic = 1
            var maxHarmonic = 1
            let frequency = rootFrequency * pow(2, octave)
            octave += octaveStepSize
            while harmonic * frequency < nyquist {
                maxHarmonic = harmonic
                harmonic += 1
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
    public class func harmonicFrequencyRange(f0: Double = 130.8127826503, f1: Double = 2093.0045224048, wavetableCount: Int = 12) -> [(Double, Int)] {
        let nyquist = 22_050.0
        var retVal = [(Double, Int)]()
        for i in 0..<wavetableCount {
            var harmonic = 1
            var maxHarmonic = 1
            let frequency = f0 + (f1 - f0) * i / (wavetableCount - 1)
            while harmonic * frequency < nyquist {
                maxHarmonic = harmonic
                harmonic += 1
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
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
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
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
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
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
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
            let c: Float = ((2 * a) / (Float(harmonic) * 3.141_592_65)) * sin( Float(harmonic * 3.141_592_65 * d) )
            return c
        }

        // offset the samples by 1/2 period
        let sampleOffset = Int(period * count * 0.5)

        for h in 1...harmonicCount {
            for i in indices {
                let x = Float(coefficient(h) * cos(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
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
        var min: Float = 999999
        var max: Float = -999999
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
        for i in 0..<indices.count/2 {
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

    /// In-place phase offset
    /// Parameters:
    ///   - offset: phase on [0, 1]
    public func phase(offset: Float = 0) {
        let p = Int(indices.count * offset)
        for i in indices {
            let j = (i + p) % indices.count
            let tmp = self[i]
            self[i] = self[j]
            self[j] = tmp
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
