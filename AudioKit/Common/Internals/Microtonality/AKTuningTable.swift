//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 3/17/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Tuning table stores frequencies at which to play MIDI notes
@objc open class AKTuningTable: NSObject {

    // Some definitions:
    // f = Frequency
    // p = Pitch = log2(frequency) for tunings where octave powers of 2
    // c = Cents = 1200 * Pitch
    // nn = midi note number of any tuning.  maps to frequency in this tuning table.
    
    // Regarding MIDI/Pitchbend ("etNNPitchBend") scheme:
    // etnn or 12ETNN = midi note number of 12ET.  1 12ETNN = 1 semitone = 100 cents
    // The greater your tolerance for numerical precision the less voice-stealing will happen with midi/pitchbend schemes
    
    
    /// For clarity, typealias Frequency as a Double
    public typealias Frequency = Double
    
    /// For clarify, typealias Cents as a Double.
    /// Cents = 1200 * log2(Frequency)
    public typealias Cents = Double

    /// Standard Nyquist frequency
    private static let NYQUIST: Frequency = AKSettings.sampleRate / 2

    /// Total number of MIDI Notes available to play
    public static let midiNoteCount = 128

    /// Note number for standard reference note
    public var middleCNoteNumber: MIDINoteNumber = 60 {
        didSet {
            updateTuningTable()
        }
    }

    /// Frequency of standard reference note
    /// equivalent to noteToHz: return 440. * exp2((60 - 69)/12.)
    public var middleCFrequency: Frequency = 261.625_565_300_6 {
        didSet {
            updateTuningTable()
        }
    }

    /// Octave number for standard reference note.  Can be negative
    /// ..., -2, -1, 0, 1, 2, ...
    public var middleCOctave: Int = 0 {
        didSet {
            updateTuningTable()
        }
    }
    
    /// Range of downwards Pitch Bend used in etNN calculation.  Must match your synthesizer's pitch bend DOWN range
    public var etNNPitchBendRangeDown: Cents = -50 {
        didSet {
            updateTuningTable()
        }
    }
    private let pitchBendLow: Double = 0
    
    /// Range of upwards Pitch Bend used in etNN calculation.  Must match your synthesizer's pitch bend UP range
    public var etNNPitchBendRangeUp: Cents = 50 {
        didSet {
            updateTuningTable()
        }
    }
    
    private let pitchBendHigh: Double = 16383

    /// Given the tuning table's MIDINoteNumber NN return a tuple of the equivalent 12ET MIDINoteNumber plus Pitch Bend
    /// Returns nil if the tuning table's MIDINoteNumber cannot be mapped to 12ET
    /// - parameter NN: The tuning table's Note Number
    /// - parameter etNN: Note number of 12ET.  1 etNN = 100 cents (i.e., semitone)
    /// - parameter pitchBend: on [0,16383]
    public func etNNPitchBend(NN nn: MIDINoteNumber) -> (etNN: MIDINoteNumber, pitchBend: Int)? {
        return etNNDictionary[nn]
    }
    
    private var etNNDictionary: Dictionary<MIDINoteNumber, (etNN: MIDINoteNumber, pitchBend: Int)> = Dictionary<MIDINoteNumber, (etNN: MIDINoteNumber, pitchBend: Int)>()

    
    private var content = [Frequency](repeating: 1.0, count: midiNoteCount)
    
    private var frequencies = [Frequency]()

    /// Initialization for standard default 12 tone equal temperament
    public override init() {
        super.init()
        defaultTuning()
    }

    /// Return the Frequency for the given MIDINoteNumber
    public func frequency(forNoteNumber noteNumber: MIDINoteNumber) -> Frequency {
        return content[Int(noteNumber)]
    }

    /// Set Frequency of the given note number: Make your own tunings.
    public func setFrequency(_ frequency: Frequency, at noteNumber: MIDINoteNumber) {
        content[Int(noteNumber)] = frequency
    }

    /// Create the tuning using the input frequencies
    ///
    /// - parameter fromFrequencies: An array of Frequencies
    ///
    public func tuningTable(fromFrequencies inputFrequencies: [Frequency]) {
        if inputFrequencies.isEmpty {
            AKLog("No input frequencies")
            return
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
            return
        }

        // sort
        let frequenciesOctaveReducedSorted = frequenciesOctaveReduce.sorted { $0 < $1 }
        frequencies = frequenciesOctaveReducedSorted

        // provide an optional uniquify.
        // Choose epsilon for frequency equality comparison

        // update
        updateTuningTable()
    }

    // Assume frequencies are set and valid:  Process and update tuning table and etNNPitchBend dictionary
    private func updateTuningTable() {
        //AKLog("Frequencies: \(frequencies)")
        
        etNNDictionary.removeAll(keepingCapacity: true)
        
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
            
            // UPDATE etNNPitchBend
            if f <= 0 { continue } // DEFENSIVE: in case clamp above is removed
            let freqAs12ETNN = Double(middleCNoteNumber) + 12 * log2(f / middleCFrequency)
            if freqAs12ETNN >= 0 && freqAs12ETNN < Double(AKTuningTable.midiNoteCount) {
                let etnnt = modf(freqAs12ETNN)
                var nnAs12ETNN = MIDINoteNumber(etnnt.0) // integer part "12ET note number"
                var etnnpbf = 100 * etnnt.1  // convert fractional part to Cents
                // if fractional part is [0.5,1.0] then flip it: add one to note number and negate pitchbend.
                if etnnpbf >= 50 && nnAs12ETNN < MIDINoteNumber(AKTuningTable.midiNoteCount - 1) {
                    nnAs12ETNN = nnAs12ETNN + 1
                    etnnpbf = -(100 - etnnpbf)
                }
                let netnnpbf = etnnpbf/(etNNPitchBendRangeUp - etNNPitchBendRangeDown)
                if netnnpbf >= -0.5 && netnnpbf <= 0.5 {
                    let netnnpb = Int( (netnnpbf + 0.5) * (pitchBendHigh - pitchBendLow) + pitchBendLow )
                    etNNDictionary[MIDINoteNumber(i)] = (etNN: nnAs12ETNN, pitchBend: netnnpb)
                } else {
                    AKLog("this tuning's note number:\(i) is in range of 12ET note numbers:\(freqAs12ETNN) but pitch bend is not:\(etnnpbf)")
                }
            } else {
                AKLog("this tuning's note number:\(i) is out of range of 12ET note numbers:\(freqAs12ETNN)")
            }
        }
        AKLog("etnn dictionary:\(etNNDictionary)")
    }
}
