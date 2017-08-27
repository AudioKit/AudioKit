//
//  AKTuningTable+EqualTemperament.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    /// Default tuning table is 12ET.
    public func defaultTuning() {
        twelveToneEqualTemperament()
    }

    /// Create 12-tone equal temperament
    public func twelveToneEqualTemperament() {
        equalTemperament(notesPerOctave: 12)
    }

    /// Create 31-tone equal temperament
    public func thirtyOneEqualTemperament() {
        equalTemperament(notesPerOctave: 31)
    }

    /// Create an equal temperament with notesPerOctave
    /// From Erv Wilson.  See http://anaphoria.com/MOSedo.pdf
    ///
    /// - parameter notesPerOctave: Divide the octave equally by this many steps
    ///
    public func equalTemperament(notesPerOctave: Int) {
        var nf = [Frequency](repeatElement(1.0, count: notesPerOctave))
        for i in 0 ..< notesPerOctave {
            nf[i] = Frequency(pow(2.0, Frequency(Frequency(i) / notesPerOctave)))
        }
        tuningTable(fromFrequencies: nf)
    }
}
