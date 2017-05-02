//
//  AKTuningTable+Brun.swift
//  AudioKit For iOS
//
//  Created by Marcus W. Hobbs on 5/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {
    
    // only public while developing...intend to make private
    public static func brunLevel_0_1_1_0(level l:Int, generator g:Double) -> (numerator:Int, denominator:Int) {
        var zn:Int = 0, zd:Int = 1, infn:Int = 1, infd:Int = 0, fn:Int = 0, fd:Int = 0
        
        for _ in 0..<l {
            fn = zn + infn
            fd = zd + infd
            if g > Double(fn)/Double(fd) {
                zn = fn
                zd = fd
            }    else {
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
    ///
    public func momentOfSymmetry(generator g_in:Double, level l_in:Int) {
        let g = (g_in > 1.0) ?1.0 :((g_in < 0.0) ?0.0 :g_in)
        let l = (l_in > 7) ?7 :((l_in < 0) ?0 :l_in)
        let d = AKTuningTable.brunLevel_0_1_1_0(level: l, generator: g)
        let den = d.denominator
        var f = [Frequency]()
        for i in 0..<den {
            let p = exp2( (Double(i)*g).truncatingRemainder(dividingBy: 1.0) )
            f.append(Frequency(p))
        }
        f = f.sorted { $0 < $1 }
        
        tuningTable(fromFrequencies: f)
    }

    // Examples:
    //
    // 12ET:
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.583333, level: 5)
    
    // 9-tone scale
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238186, level: 5)
    
    // 9-tone scale
    // AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.264100, level: 5)
}
