//
//  AKTuningTable+Wilson.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    public func presetHighlandBagPipes() -> Int {
        tuningTable(fromFrequencies: [32, 36, 39, 171, 48, 52, 57])
        return 7
    }

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    public func presetDiaphonicTetrachord() -> Int {
        tuningTable(fromFrequencies: [1, 27 / 26.0, 9 / 8.0, 4 / 3.0, 18 / 13.0, 3 / 2.0, 27 / 16.0])
        return 7
    }

}
