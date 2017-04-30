//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {
    
    public func tetrany_major(_ A:Frequency, _ B:Frequency, _ C:Frequency, _ D:Frequency) {
        tuningTable(fromFrequencies: [A, B, C, D])
    }

    public func hexany(_ A:Frequency, _ B:Frequency, _ C:Frequency, _ D:Frequency) {
        tuningTable(fromFrequencies: [A*B, A*C, A*D, B*C, B*D, C*D])
    }

    public func tetrany_minor(_ A:Frequency, _ B:Frequency, _ C:Frequency, _ D:Frequency) {
        tuningTable(fromFrequencies: [A * B * C, A * B * D, A * C * D, B * C * D])
    }
    
}
