//
//  AKTuningTable+Brun.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 5/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {

    // Viggo Brun algorithm
    // return (numerator, denominator) approximation to generator after level iterations
    fileprivate static func brunLevel_0_1_1_0(level l: Int, generator g: Double) -> (numerator: Int, denominator: Int) {
        var zn: Int = 0, zd: Int = 1, infn: Int = 1, infd: Int = 0, fn: Int = 0, fd: Int = 0

        for _ in 0..<l {
            fn = zn + infn
            fd = zd + infd
            if g > Double(fn) / Double(fd) {
                zn = fn
                zd = fd
            } else {
                infn = fn
                infd = fd
            }
        }
        return (numerator:fn, denominator:fd)
    }

    /// Creates a "Nested 2-interval pattern", or "Moment of Symmetry"
    ///
    /// - parameter generator: A Double on [0, 1]
    /// - parameter level: An Int on [0, 7]
    /// - parameter murchana: The mode of the scale...degrees are normalized by the frequency at this index
    /// - returns: Number of notes per octave
    /// From Erv Wilson.  See http://anaphoria.com/wilsonintroMOS.html
    public func momentOfSymmetry(generator g_in: Double = 7.0 / 12.0, level l_in: Int = 5, murchana m_in: Int = 0) -> Int {
        // clamp
        let g = (g_in > 1.0) ?1.0 :((g_in < 0.0) ?0.0 :g_in)
        let l = (l_in > 7) ?7 :((l_in < 0) ?0 :l_in)
        let d = AKTuningTable.brunLevel_0_1_1_0(level: l, generator: g)

        // number of notes per octave (npo)
        let den = d.denominator
        var f = [Frequency]()
        for i in 0..<den {
            let p = exp2( (Double(i) * g).truncatingRemainder(dividingBy: 1.0) )
            f.append(Frequency(p))
        }

        // apply murchana then octave reduce
        let m = (m_in > den) ?(den - 1) :((m_in < 0) ?0 :m_in)
        let murchana = f[m]
        f = f.map({(frequency: Frequency) -> Frequency in
            var ff = frequency / murchana
            while ff < 1.0 {
                ff = ff * 2.0
            }
            while ff >= 2.0 {
                ff = ff / 2.0
            }
            return ff
        })

        // sort
        f = f.sorted { $0 < $1 }

        // update tuning table
        tuningTable(fromFrequencies: f)

        return den
    }

    // Examples:
    //
    // 12ET:
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.583333, level: 6) -> 12

    // 9-tone scale
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238186, level: 5) -> 9

    // 9-tone scale
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.264100, level: 5) -> 9
}
