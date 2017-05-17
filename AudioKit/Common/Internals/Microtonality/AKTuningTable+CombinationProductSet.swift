//
//  AKTuningTable+CombinationProductSet.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    //swiftlint:disable variable_name

    /// Create a hexany from 4 frequencies (4 choose 2)
    ///
    /// - parameter A, B, C, D: Master set of frequencies
    /// From Erv Wilson.  See http://anaphoria.com/dal.pdf and http://anaphoria.com/hexany.pdf
    public func hexany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A * B, A * C, A * D, B * C, B * D, C * D])
        return 6
    }

    /// Create a major tetrany from 4 frequencies (4 choose 1)
    ///
    /// - parameter A, B, C, D: Master set of frequencies
    ///
    public func majorTetrany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A, B, C, D])
        return 4
    }

    /// Create a hexany from 4 frequencies (4 choose 3)
    ///
    /// - parameter A, B, C, D: Master set of frequencies
    ///
    public func minorTetrany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A * B * C, A * B * D, A * C * D, B * C * D])
        return 4
    }

}
