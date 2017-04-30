//
//  AKTuningTable.swift
//  AudioKit
//
//  Created by Marcus W. Hobbs on 4/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {
    
    // From Erv Wilson
    static let persianNorthIndianMasterSet:[Frequency] = [
        1 / 1,
        135 / 128,
        10 / 9,
        9 / 8,
        1215 / 1024,
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
    
    fileprivate func helper(_ input:[Int]) -> [Frequency] {
        assert(input.count < AKTuningTable.persianNorthIndianMasterSet.count - 1, "internal error: index out of bounds")
        let retVal:[Frequency] = input.map({(number: Int) -> Frequency in
            return Frequency(AKTuningTable.persianNorthIndianMasterSet[number])
        })
        return retVal
    }
    
    public func presetPersian17NorthIndian00_17() {
        let h = helper([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian01Kalyan() {
        let h = helper([0,3,5,8,10,12,15])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian02Bilawal() {
        let h = helper([0,3,5,7,10,13,15])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian03Khamaj() {
        let h = helper([0,3,5,7,10,12,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian04KafiOld() {
        let h = helper([0,2,4,7,10,12,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian05Kafi() {
        let h = helper([0,3,4,7,10,13,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian06Asawari() {
        let h = helper([0,3,4,7,10,11,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian07Bhairavi() {
        let h = helper([0,1,4,7,10,11,14])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian08Marwa() {
        let h = helper([0,1,5,8,10,12,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian09Purvi() {
        let h = helper([0,1,5,8,10,11,15])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian10Lalit2() {
        let h = helper([0,1,5,7,8,12,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian11Todi() {
        let h = helper([0,1,4,8,10,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian12Lalit() {
        let h = helper([0,1,5,7,8,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian13NoName() {
        let h = helper([0,1,4,8,10,11,14])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian14AnandBhairav() {
        let h = helper([0,1,5,7,10,12,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian15Bhairav() {
        let h = helper([0,1,5,7,10,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian16JogiyaTodi() {
        let h = helper([0,1,4,7,10,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian17Madhubanti() {
        let h = helper([0,3,4,8,10,12,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian18NatBhairav() {
        let h = helper([0,3,5,7,10,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian19AhirBhairav() {
        let h = helper([0,1,5,7,10,12,14])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian20ChandraKanada() {
        let h = helper([0,3,4,7,10,11,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian21BasantMukhari() {
        let h = helper([0,1,5,7,10,11,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian22Champakali() {
        let h = helper([0,3,6,8,10,13,14])
        tuningTable(fromFrequencies: h)
    }
    
    public func presetPersian17NorthIndian23Patdeep() {
        let h = helper([0,3,4,7,10,13,15])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian24MohanKauns() {
        let h = helper([0,3,5,7,10,11,14])
        tuningTable(fromFrequencies: h)
    }

    public func presetPersian17NorthIndian25Parameswari() {
        let h = helper([0,1,4,7,10,12,14])
        tuningTable(fromFrequencies: h)
    }

}
