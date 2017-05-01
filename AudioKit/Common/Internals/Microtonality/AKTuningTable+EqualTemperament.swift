//
//  AKTuningTable+EqualTemperament.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    // Default tuning table is 12ET.
    public func defaultTuning() {
        twelveToneEqualTemperament()
    }

    public func twelveToneEqualTemperament() {
        equalTemperament(notesPerOctave: 12)
    }

    public func thirtyOneEqualTemperament() {
        equalTemperament(notesPerOctave: 31)
    }

    public func equalTemperament(notesPerOctave npo: Int) {
        var nf = [Frequency](repeatElement(1.0, count: npo))
        for i in 0 ..< npo {
            nf[i] = Frequency(pow(2.0, Frequency(Frequency(i) / npo)))
        }
        tuningTable(fromFrequencies: nf)
    }
}
