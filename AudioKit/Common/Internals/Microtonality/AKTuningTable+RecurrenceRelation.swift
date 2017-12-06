//
//  AKTuningTable+RecurrenceRelation.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    @discardableResult public func presetRecurrenceRelation01() -> Int {
        return tuningTable(fromFrequencies: [1, 34, 5, 21, 3, 13, 55])
    }
}
