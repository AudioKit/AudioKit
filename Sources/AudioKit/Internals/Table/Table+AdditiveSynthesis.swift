// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Accelerate

extension Table {
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

    /// Harmonic Pitch Range for given root frequency and octave step size
    /// - Parameters:
    ///   - rootFrequency: Root frequency in Hertz
    ///   - octaveStepSize: Octave step size as a multiplier, default 1.
    /// - Returns: Array of frequencies and the associated maximum harmonic value
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

        let coefficient = { (harmonic: Int) -> Float in
            1 / Float(harmonic)
        }

        for h in 1...harmonicCount {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
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

        let coefficient = { (harmonic: Int) -> Float in
            Float(harmonic % 2) / Float(harmonic)
        }

        for h in 1...harmonicCount {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
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

        let coefficient = { (harmonic: Int) -> Float in
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
                self[i] += Float(coefficient(h) * sin(Float(h) * 2.0 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
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

        let coefficient = { (harmonic: Int) -> Float in
            let c: Float = ((2.0 * a) / (Float(harmonic) * 3.14_159_265)) * sin(Float(Float(harmonic) * 3.14_159_265 * d))
            return c
        }

        // offset the samples by 1/2 period
        let sampleOffset = Int(period * Float(count) * 0.5)

        for h in 1...harmonicCount {
            for i in indices {
                let x = Float(coefficient(h) * cos(Float(h) * 2.0 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
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
            Log("absMax = \(absMax): NOW NORMALIZED")
        } else {
            Log("absMax = \(absMax): NOT NORMALIZED")
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
    public func msd(t: Table) -> Element {
        var msd: Element = 0
        for i in indices {
            var d: Element = self[i] - t[i]
            d *= d
            msd += d
        }
        msd = sqrt(msd) / Element(indices.count)

        return msd
    }

    /// Create an array of a specified number of tables by interpolating between the inputted array of tables
    /// Parameters:
    ///   - inputTables: tables to be interpolated between
    ///   - numberOfDesiredTables: total number of tables in resulting array
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public class func createInterpolatedTables(inputTables: [Table], numberOfDesiredTables: Int = 256) -> [Table] {
        var interpolatedTables: [Table] = []
        let thresholdForExact = 0.01 * Double(inputTables.count)
        let rangeValue = (Double(numberOfDesiredTables) / Double(inputTables.count - 1)).rounded(.up)

        for index in 1...numberOfDesiredTables {
            let waveformIndex = Int(Double(index - 1) / rangeValue)
            let interpolatedIndex = (Double(index - 1) / rangeValue).truncatingRemainder(dividingBy: 1.0)

            /// if we are nearly exactly at one of our input tables - use the input table for this index value
            if (1.0 - interpolatedIndex) < thresholdForExact {
                interpolatedTables.append(inputTables[waveformIndex + 1])
            } else if interpolatedIndex < thresholdForExact {
                interpolatedTables.append(inputTables[waveformIndex])
            }

            /// between tables - interpolate
            else {
                /// linear interpolate to get array of floats existing between the two tables
                let interpolatedFloats = [Float](vDSP.linearInterpolate([Float](inputTables[waveformIndex]),
                                                                        [Float](inputTables[waveformIndex + 1]),
                                                                        using: Float(interpolatedIndex)))
                interpolatedTables.append(Table(interpolatedFloats))
            }
        }
        return interpolatedTables
    }

    /// Takes an array of tables and resamples each table to have a lesser number of samples.
    /// Returns an array of downsampled tables
    ///
    /// Parameters:
    ///   - inputTables: array of tables - which we can assume have a large sample count
    ///   - sampleCount: the number of floating point values to which we will downsample each Table array count
    public class func downSampleTables(inputTables: [Table], to sampleCount: Int = 64) -> [Table] {
        let numberOfInputSamples = inputTables[0].content.count
        let inputLength = vDSP_Length(numberOfInputSamples)

        let filterLength: vDSP_Length = 2
        let filter = [Float](repeating: 1 / Float(filterLength), count: Int(filterLength))

        let decimationFactor = numberOfInputSamples / sampleCount
        let outputLength = vDSP_Length((inputLength - filterLength) / vDSP_Length(decimationFactor))

        var outputTables: [Table] = []
        for inputTable in inputTables {
            var outputSignal = [Float](repeating: 0, count: Int(outputLength))
            vDSP_desamp(inputTable.content,
                        decimationFactor,
                        filter,
                        &outputSignal,
                        outputLength,
                        filterLength)
            outputTables.append(Table(outputSignal))
        }
        return outputTables
    }

    /// Takes a large array of floating point values and splits them up into an array of Tables.
    /// Returns an array of tables
    /// If there are extra samples at the end of the signal that are less than tableLength, they are ommitted.
    ///
    /// Parameters:
    ///   - signal: large array of floating point values
    ///   - tableLength: number of floating point values to be stored per table
    public class func chopAudioToTables(signal: [Float], tableLength: Int = 2_048) -> [Table] {
        let numberOfSamples = signal.count
        let numberOfOutputTables = numberOfSamples / tableLength
        var outputTables: [Table] = []
        for index in 0..<numberOfOutputTables {
            let startIndex = index * tableLength
            let endIndex = startIndex + tableLength
            outputTables.append(Table(Array(signal[startIndex..<endIndex])))
        }
        return outputTables
    }

    /// Creates an array of tables from a url to an audio file
    ///
    /// Parameters:
    ///   - url: URL to audio file
    ///   - tableLength: number of floating point value samples per table (Default: 2048)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public class func createWavetableArray(_ url: URL, tableLength: Int = 2_048) -> [Table]? {
        if let audioInformation = loadAudioSignal(audioURL: url) {
            let signal = audioInformation.signal
            let tables = Table.chopAudioToTables(signal: signal, tableLength: tableLength)
            return Table.createInterpolatedTables(inputTables: tables)
        }
        return nil
    }
}
