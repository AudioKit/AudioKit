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
    /// From Erv Wilson.  See http://anaphoria.com/dal.pdf and http://anaphoria.com/hexany.pdf
    ///
    /// - Parameters:
    ///   - A: First of the master set of frequencies
    ///   - B: Second of the master set of frequencies
    ///   - C: Third of the master set of frequencies
    ///   - D: Fourth of the master set of frequencies
    ///
    @discardableResult public func hexany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A * B, A * C, A * D, B * C, B * D, C * D])
        return 6
    }

    /// Create a major tetrany from 4 frequencies (4 choose 1)
    ///
    /// - Parameters:
    ///   - A: First of the master set of frequencies
    ///   - B: Second of the master set of frequencies
    ///   - C: Third of the master set of frequencies
    ///   - D: Fourth of the master set of frequencies
    ///
    @discardableResult public func majorTetrany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A, B, C, D])
        return 4
    }

    /// Create a hexany from 4 frequencies (4 choose 3)
    ///
    /// - Parameters:
    ///   - A: First of the master set of frequencies
    ///   - B: Second of the master set of frequencies
    ///   - C: Third of the master set of frequencies
    ///   - D: Fourth of the master set of frequencies
    ///
    @discardableResult public func minorTetrany(_ A: Frequency, _ B: Frequency, _ C: Frequency, _ D: Frequency) -> Int {
        tuningTable(fromFrequencies: [A * B * C, A * B * D, A * C * D, B * C * D])
        return 4
    }

}
