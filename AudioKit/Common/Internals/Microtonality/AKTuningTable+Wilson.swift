//
//  AKTuningTable+Wilson.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKTuningTable {

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    @objc public func presetHighlandBagPipes() -> Int {
        let npo = tuningTable(fromFrequencies: [32, 36, 39, 171, 48, 52, 57])
        return npo
    }

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    @objc public func presetDiaphonicTetrachord() -> Int {
        let npo = tuningTable(fromFrequencies: [1, 27 / 26.0, 9 / 8.0, 4 / 3.0, 18 / 13.0, 3 / 2.0, 27 / 16.0])
        return npo
    }

}
