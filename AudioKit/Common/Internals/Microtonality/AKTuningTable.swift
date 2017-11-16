//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 3/17/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Tuning table stores frequencies at which to play MIDI notes
@objc open class AKTuningTable: NSObject {

    /// For clarity, typealias Frequency as a Double
    public typealias Frequency = Double

    /// Standard Nyquist frequency
    private static let NYQUIST: Frequency = AKSettings.sampleRate / 2

    /// Total number of MIDI Notes available to play
    @objc public static let midiNoteCount = 128

    /// Note number for standard reference note
    @objc public var middleCNoteNumber: MIDINoteNumber = 60 {
        didSet {
            updateTuningTable()
        }
    }

    /// Frequency of standard reference note
    /// equivalent to noteToHz: return 440. * exp2((60 - 69)/12.)
    @objc public var middleCFrequency: Frequency = 261.625_565_300_6 {
        didSet {
            updateTuningTable()
        }
    }

    /// Octave number for standard reference note.  Can be negative
    /// ..., -2, -1, 0, 1, 2, ...
    @objc public var middleCOctave: Int = 0 {
        didSet {
            updateTuningTable()
        }
    }

    @objc private var content = [Frequency](repeating: 1.0, count: midiNoteCount)
    @objc private var frequencies = [Frequency]()

    /// Initialization for standard default 12 tone equal temperament
    @objc public override init() {
        super.init()
        _ = defaultTuning()
    }

    /// Pull out frequency information for a given note number
    @objc public func frequency(forNoteNumber noteNumber: MIDINoteNumber) -> Frequency {
        return content[Int(noteNumber)]
    }

    /// Set frequency of a given note number
    @objc public func setFrequency(_ frequency: Frequency, at noteNumber: MIDINoteNumber) {
        content[Int(noteNumber)] = frequency
    }

    /// Create the tuning using the input frequencies
    ///
    /// - parameter inputFrequencies: An array of frequencies
    ///
    @objc @discardableResult public func tuningTable(fromFrequencies inputFrequencies: [Frequency]) -> Int {
        if inputFrequencies.isEmpty {
            AKLog("No input frequencies")
            return 0
        }

        // octave reduce
        var frequenciesAreValid = true
        let frequenciesOctaveReduce = inputFrequencies.map({(frequency: Frequency) -> Frequency in
            if frequency == 0 {
                frequenciesAreValid = false
                return Frequency(1)
            }

            var l2 = abs(frequency)

            while l2 < 1 {
                l2 *= 2.0
            }
            while l2 >= 2 {
                l2 /= 2.0
            }

            return l2
        })

        if ❗️frequenciesAreValid {
            AKLog("Invalid input frequencies")
            return 0
        }

        // sort
        let frequenciesOctaveReducedSorted = frequenciesOctaveReduce.sorted { $0 < $1 }
        frequencies = frequenciesOctaveReducedSorted

        // provide an optional uniquify.
        // Choose epsilon for frequency equality comparison

        // update
        updateTuningTable()

        return frequencies.count
    }

    // Assume frequencies are set and valid:  Process and update tuning table.
    @objc private func updateTuningTable() {
        //AKLog("Frequencies: \(frequencies)")
        for i in 0 ..< AKTuningTable.midiNoteCount {
            let ff = Frequency(i - Int(middleCNoteNumber)) / Frequency(frequencies.count)
            var ttOctaveFactor = Frequency(trunc(ff))
            if ff < 0 {
                ttOctaveFactor -= 1
            }
            var frac = fabs(ttOctaveFactor - ff)
            if frac == 1 {
                frac = 0
                ttOctaveFactor += 1
            }
            let frequencyIndex = Int(round(frac * Frequency(frequencies.count)))
            let tone = Frequency(frequencies[frequencyIndex])
            let lp2 = pow(2, ttOctaveFactor)
            var f = tone * lp2 * middleCFrequency

            f = (0...AKTuningTable.NYQUIST).clamp(f)

            content[i] = Frequency(f)
        }
    }
}
