//
//  AKTuningTable+EqualTemperament.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKTuningTable {

    /// Default tuning table is 12ET.
    public func defaultTuning() -> Int {
        return twelveToneEqualTemperament()
    }

    /// Create 12-tone equal temperament
    public func twelveToneEqualTemperament() -> Int {
        return equalTemperament(notesPerOctave: 12)
    }

    /// Create 31-tone equal temperament
    public func thirtyOneEqualTemperament() -> Int {
        return equalTemperament(notesPerOctave: 31)
    }

    /// Create an equal temperament with notesPerOctave
    ///
    /// - parameter notesPerOctave divides the octave equally by this many steps
    /// From Erv Wilson.  See http://anaphoria.com/MOSedo.pdf
    public func equalTemperament(notesPerOctave npo: Int) -> Int {
        var nf = [Frequency](repeatElement(1.0, count: npo))
        for i in 0 ..< npo {
            nf[i] = Frequency(pow(2.0, Frequency(Frequency(i) / npo)))
        }
        _ = tuningTable(fromFrequencies: nf)
        return npo
    }
}
