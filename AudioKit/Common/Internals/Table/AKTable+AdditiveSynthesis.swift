//
//  AKTable+AKSynthOne.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 7/23/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AKTable {

    /// This method will start at rootFrequency * octave, and will halt when this is above nyquist.
    /// This method outputs an array where each entry is the maximum number of harmonics for the frequency.
    /// This method is "pitch"-based, which may not be the best way to maximize harmonics.
    ///
    /// Parameters:
    ///   - rootFrequency: the lowest frequency wavetable.  8.17579891564375 corresponds to C0, or nn = 0
    ///   - octaveStepSize: fractions of an octave (i.e., 1).
    ///
    func harmonicRange(rootFrequency: Double = 8.17579891564375, octaveStepSize: Double = 1) -> [(Double, Int)] {
        let nyquist = 22_050.0
        var i = 0
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
                //print(i, frequency, maxHarmonic) // -2 i.e., C-2, C-1, C0, C1, etc.
                retVal.append((frequency, maxHarmonic))
                i += 1
            }
        }
        return retVal
    }

    // set table to sum of sines approximating a sawtooth.
    // For efficiency you can reuse the result of the table by setting clear to false, or not by setting clear to true.
    func sawtooth(numberOfHarmonics: Int = 1_024, clear: Bool = true) {
        self.phase = 0

        if clear {
            for i in indices {
                self[i] = 0
            }
        }

        let coefficient = {(harmonic: Int) -> Float in
            return 1 / Float(harmonic)
        }

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // Set table to sum of sines approximating a square.
    // For efficiency you can reuse the result of the table by setting clear to false, or not by setting clear to true.
    func square(numberOfHarmonics: Int = 1_024, clear: Bool = true) {
        self.phase = 0

        if clear {
            for i in indices {
                self[i] = 0
            }
        }

        let coefficient = {(harmonic: Int) -> Float in
            return Float(harmonic % 2) / Float(harmonic)
        }

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // Set table to sum of sines approximating a triangle.
    // For efficiency you can reuse the result of the table by setting clear to false, or not by setting clear to true.
    func triangle(numberOfHarmonics: Int = 1_024, clear: Bool = true) {
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

        for h in 1..<numberOfHarmonics {
            for i in indices {
                self[i] += Float(coefficient(h) * sin(h * 2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
            }
        }
    }

    // Set table to sum of sines approximating a pwm with a period.
    // Due to DC component, and scaling/normalizing, a "clear" parameter is not provided.
    func pwm(numberOfHarmonics: Int = 1_024, period: Float = 1 / 8) {
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

        // offset the samples by the period
        let sampleOffset = Int(period * count)

        for h in 1..<numberOfHarmonics {
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
}
