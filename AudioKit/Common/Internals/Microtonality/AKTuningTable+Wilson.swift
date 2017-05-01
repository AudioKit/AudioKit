
//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    // From Erv Wilson
    public func presetHighlandBagPipes() {
        tuningTable(fromFrequencies: [32, 36, 39, 171, 48, 52, 57])
    }
    
    public func presetDiaphonicTetrachord() {
        tuningTable(fromFrequencies: [1, 27 / 26.0, 9 / 8.0, 4 / 3.0, 18 / 13.0, 3 / 2.0, 27 / 16.0])
    }
    
}
