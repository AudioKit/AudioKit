//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// helper object to simulate a Swift tuple for ObjC interoperability
open class AKTuningTableETNN: NSObject {
    @objc public var nn: MIDINoteNumber = 60
    @objc public var pitchBend: Int = 16_384 / 2
    public init(_ nn: MIDINoteNumber = 60, _ pb: Int = 16_384 / 2) {
        self.nn = nn
        self.pitchBend = pb
    }
}

/// helper object to simulate a Swift tuple for ObjC interoperability
open class AKTuningTableDelta12ET: NSObject {
    @objc public var nn: MIDINoteNumber = 60
    @objc public var cents: Double = 0
    public init(_ nn: MIDINoteNumber = 60, _ cents: Double = 0) {
        self.nn = nn
        self.cents = cents
    }
}

///AKTuningTable provides high-level methods to create musically useful tuning tables

// Definitions:
// masterSet = an octave-based array of linear frequencies, processed to spread across all midi note numbers
open class AKTuningTable: AKTuningTableBase {

    @objc private(set) public var masterSet = [Frequency]()

    /// Note number for standard reference note
    @objc public var middleCNoteNumber: MIDINoteNumber = 60 {
        didSet {
            updateTuningTableFromMasterSet()
        }
    }

    /// Frequency of standard reference note
    /// equivalent to noteToHz: return 440. * exp2((60 - 69)/12.)
    @objc public var middleCFrequency: Frequency = 261.625_565_300_6 {
        didSet {
            updateTuningTableFromMasterSet()
        }
    }

    /// Octave number for standard reference note.  Can be negative
    /// ..., -2, -1, 0, 1, 2, ...
    @objc public var middleCOctave: Int = 0 {
        didSet {
            updateTuningTableFromMasterSet()
        }
    }

    /// Range of downwards Pitch Bend used in etNN calculation.  Must match your synthesizer's pitch bend DOWN range
    /// etNNPitchBendRangeDown and etNNPitchBendRangeUp must cover a spread that is greater than the maximum distance between two notes in your octave.
    @objc public var etNNPitchBendRangeDown: Cents = -50 {
        didSet {
            updateTuningTableFromMasterSet()
        }
    }

    internal let pitchBendLow: Double = 0

    /// Range of upwards Pitch Bend used in etNN calculation.  Must match your synthesizer's pitch bend UP range
    /// etNNPitchBendRangeDown and etNNPitchBendRangeUp must cover a spread that is greater than the maximum distance between two notes in your octave.
    @objc public var etNNPitchBendRangeUp: Cents = 50 {
        didSet {
            updateTuningTableFromMasterSet()
        }
    }

    internal let pitchBendHigh: Double = 16_383

    internal var etNNDictionary = Dictionary<MIDINoteNumber, AKTuningTableETNN>()

    /// Given the tuning table's MIDINoteNumber NN return an AKTuningTableETNN of the equivalent 12ET MIDINoteNumber plus Pitch Bend
    /// Returns nil if the tuning table's MIDINoteNumber cannot be mapped to 12ET
    /// - parameter nn: The tuning table's Note Number
    @objc public func etNNPitchBend(NN nn: MIDINoteNumber) -> AKTuningTableETNN? {
        return etNNDictionary[nn]
    }

    internal var delta12ETDictionary = Dictionary<MIDINoteNumber, AKTuningTableDelta12ET>()

    /// Given the tuning table's MIDINoteNumber NN return an AKTuningTableETNN of the equivalent 12ET MIDINoteNumber plus Pitch Bend
    /// Returns nil if the tuning table's MIDINoteNumber cannot be mapped to 12ET
    /// - parameter nn: The tuning table's Note Number
    @objc public func delta12ET(NN nn: MIDINoteNumber) -> AKTuningTableDelta12ET? {
        return delta12ETDictionary[nn]
    }

    /// Notes Per Octave: The count of the masterSet array
    @objc override public var npo: Int {
        return masterSet.count
    }

    /// Initialization for standard default 12 tone equal temperament
    public override init() {
        super.init()
        _ = defaultTuning()
    }

    /// Create the tuning using the input masterSet
    ///
    /// - parameter inputMasterSet: An array of frequencies, i.e., the "masterSet"
    ///
    @objc @discardableResult public func tuningTable(fromFrequencies inputMasterSet: [Frequency]) -> Int {
        if inputMasterSet.isEmpty {
            AKLog("No input frequencies")
            return 0
        }

        // octave reduce
        var frequenciesAreValid = true
        let frequenciesOctaveReduce = inputMasterSet.map({(frequency: Frequency) -> Frequency in
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
        masterSet = frequenciesOctaveReducedSorted

        // update
        updateTuningTableFromMasterSet()

        return masterSet.count
    }

    // Assume masterSet is set and valid:  Process and update tuning table.
    @objc internal func updateTuningTableFromMasterSet() {
        //AKLog("masterSet: \(masterSet)")

        etNNDictionary.removeAll(keepingCapacity: true)
        delta12ETDictionary.removeAll(keepingCapacity: true)

        for i in 0 ..< AKTuningTable.midiNoteCount {
            let ff = Frequency(i - Int(middleCNoteNumber)) / Frequency(masterSet.count)
            var ttOctaveFactor = Frequency(trunc(ff))
            if ff < 0 {
                ttOctaveFactor -= 1
            }
            var frac = fabs(ttOctaveFactor - ff)
            if frac == 1 {
                frac = 0
                ttOctaveFactor += 1
            }
            let frequencyIndex = Int(round(frac * Frequency(masterSet.count)))
            let tone = Frequency(masterSet[frequencyIndex])
            let lp2 = pow(2, ttOctaveFactor)

            var f = tone * lp2 * middleCFrequency
            f = (0...AKTuningTable.NYQUIST).clamp(f)
            tableData[i] = Frequency(f)

            // UPDATE etNNPitchBend
            if f <= 0 { continue } // defensive, in case clamp above is removed
            let freqAs12ETNN = Double(middleCNoteNumber) + 12 * log2(f / middleCFrequency)
            if freqAs12ETNN >= 0 && freqAs12ETNN < Double(AKTuningTable.midiNoteCount) {
                let etnnt = modf(freqAs12ETNN)
                var nnAs12ETNN = MIDINoteNumber(etnnt.0) // integer part "12ET note number"
                var etnnpbf = 100 * etnnt.1  // convert fractional part to Cents

                // if fractional part is [0.5,1.0] then flip it: add one to note number and negate pitchbend.
                if etnnpbf >= 50 && nnAs12ETNN < MIDINoteNumber(AKTuningTable.midiNoteCount - 1) {
                    nnAs12ETNN = nnAs12ETNN + 1
                    etnnpbf = etnnpbf - 100
                }
                let delta12ETpbf = etnnpbf // defensive, in case you further modify etnnpbf
                let netnnpbf = etnnpbf / (etNNPitchBendRangeUp - etNNPitchBendRangeDown)
                if netnnpbf >= -0.5 && netnnpbf <= 0.5 {
                    let netnnpb = Int( (netnnpbf + 0.5) * (pitchBendHigh - pitchBendLow) + pitchBendLow )
                    etNNDictionary[MIDINoteNumber(i)] = AKTuningTableETNN(nnAs12ETNN, netnnpb)
                    delta12ETDictionary[MIDINoteNumber(i)] = AKTuningTableDelta12ET(nnAs12ETNN, delta12ETpbf)
                } else {
                    //AKLog("this tuning's note number:\(i) is in range of 12ET note numbers:\(freqAs12ETNN) but pitch bend is not:\(etnnpbf)")
                }
            } else {
                //AKLog("this tuning's note number:\(i) is out of range of 12ET note numbers:\(freqAs12ETNN)")
            }
        }
        //AKLog("etnn dictionary:\(etNNDictionary)")
    }

    /// Renders and returns the masterSet values as an array of cents
    @objc public func masterSetInCents() -> [Cents] {
        let cents = masterSet.map({ log2($0) * 1_200 })
        return cents
    }
}
