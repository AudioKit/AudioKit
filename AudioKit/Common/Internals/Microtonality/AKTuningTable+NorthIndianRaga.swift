//
//  AKTuningTable+NorthIndianRaga.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {
  
  /// Set tuning to 22 Indian Scale.
  /// From Erv Wilson.  See http://anaphoria.com/Khiasmos.pdf
  public func khiasmos22Indian() -> Int {
    
    let masterSet: [Frequency] = [1 / 1,
                                  256 / 243,
                                  16 / 15,
                                  10 / 9,
                                  9 / 8,
                                  32 / 27,
                                  6 / 5,
                                  5 / 4,
                                  81 / 64,
                                  4 / 3,
                                  27 / 20,
                                  45 / 32,
                                  729 / 512,
                                  3 / 2,
                                  128 / 81,
                                  8 / 5,
                                  5 / 3,
                                  405 / 240,
                                  16 / 9,
                                  9 / 5,
                                  15 / 8,
                                  243 / 128]
    tuningTable(fromFrequencies: masterSet)
    return masterSet.count
  }
  
    // From Erv Wilson.  See http://anaphoria.com/genus.pdf
    static let persianNorthIndianMasterSet: [Frequency] = [
        1 / 1,
        135 / 128,
        10 / 9,
        9 / 8,
        1_215 / 1_024,
        5 / 4,
        81 / 64,
        4 / 3,
        45 / 32,
        729 / 512,
        3 / 2,
        405 / 256,
        5 / 3,
        27 / 16,
        16 / 9,
        15 / 8,
        243 / 128]
    
    fileprivate func helper(_ input: [Int]) -> [Frequency] {
        assert(input.count < AKTuningTable.persianNorthIndianMasterSet.count - 1, "internal error: index out of bounds")
        let retVal: [Frequency] = input.map({(number: Int) -> Frequency in
            return Frequency(AKTuningTable.persianNorthIndianMasterSet[number])
        })
        return retVal
    }
    
    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    public func presetPersian17NorthIndian00_17() -> Int {
        let h = helper([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian01Kalyan() -> Int {
        let h = helper([0, 3, 5, 8, 10, 12, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian02Bilawal() -> Int {
        let h = helper([0, 3, 5, 7, 10, 13, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian03Khamaj() -> Int {
        let h = helper([0, 3, 5, 7, 10, 12, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian04KafiOld() -> Int {
        let h = helper([0, 2, 4, 7, 10, 12, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian05Kafi() -> Int {
        let h = helper([0, 3, 4, 7, 10, 13, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian06Asawari() -> Int {
        let h = helper([0, 3, 4, 7, 10, 11, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian07Bhairavi() -> Int {
        let h = helper([0, 1, 4, 7, 10, 11, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian08Marwa() -> Int {
        let h = helper([0, 1, 5, 8, 10, 12, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian09Purvi() -> Int {
        let h = helper([0, 1, 5, 8, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian10Lalit2() -> Int {
        let h = helper([0, 1, 5, 7, 8, 12, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian11Todi() -> Int {
        let h = helper([0, 1, 4, 8, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian12Lalit() -> Int {
        let h = helper([0, 1, 5, 7, 8, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    @discardableResult public func presetPersian17NorthIndian13NoName() -> Int {
        let h = helper([0, 1, 4, 8, 10, 11, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian14AnandBhairav() -> Int {
        let h = helper([0, 1, 5, 7, 10, 12, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian15Bhairav() -> Int {
        let h = helper([0, 1, 5, 7, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian16JogiyaTodi() -> Int {
        let h = helper([0, 1, 4, 7, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian17Madhubanti() -> Int {
        let h = helper([0, 3, 4, 8, 10, 12, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian18NatBhairav() -> Int {
        let h = helper([0, 3, 5, 7, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian19AhirBhairav() -> Int {
        let h = helper([0, 1, 5, 7, 10, 12, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian20ChandraKanada() -> Int {
        let h = helper([0, 3, 4, 7, 10, 11, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian21BasantMukhari() -> Int {
        let h = helper([0, 1, 5, 7, 10, 11, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian22Champakali() -> Int {
        let h = helper([0, 3, 6, 8, 10, 13, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian23Patdeep() -> Int {
        let h = helper([0, 3, 4, 7, 10, 13, 15])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian24MohanKauns() -> Int {
        let h = helper([0, 3, 5, 7, 10, 11, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
    // From Erv Wilson
    public func presetPersian17NorthIndian25Parameswari() -> Int {
        let h = helper([0, 1, 4, 7, 10, 12, 14])
        tuningTable(fromFrequencies: h)
        return h.count
    }
    
}
