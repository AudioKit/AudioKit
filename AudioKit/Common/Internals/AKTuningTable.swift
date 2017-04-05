//
//  AKTuningTable.swift
//  AudioKit For iOS
//
//  Created by Marcus W. Hobbs on 3/17/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//


//TODO: Marcus: Aure, I intend to add much more functionality to this class
// including Scala file support.

import Foundation

@objc open class AKTuningTable:NSObject {
   
    public typealias Element = Double
    public static let numberOfMidiNotes = 128
    
    public var noteNumberAtMiddleC:MIDINoteNumber = 60 {
        didSet {
            updateTuningTable()
        }
    }
    
    public var frequencyAtMiddleC:Element = 261.0 {
        didSet {
            updateTuningTable()
        }
    }
    // -2, -1, 0, 1, 2, etc.
    public var octaveAtMiddleC:Int = 0  {
        didSet {
            updateTuningTable()
        }
    }
    
    private var content = [Element](repeating:1.0, count:numberOfMidiNotes)
    private var numberField=[Element]()
    
    public override init() {
        super.init()
        self.twelveToneEqualTemperament()
    }
    
    public func frequency(forNoteNumber noteNumber:MIDINoteNumber) -> Element {
        return content[Int(noteNumber)]
    }
    public func setFrequency(_ frequency:Element, at noteNumber:MIDINoteNumber) {
        content[Int(noteNumber)] = frequency
    }
    
    // Default tuning table is 12ET.
    // Note this is equivalent to 440.0*exp2((noteNumber - 69.0)/12.0))
    // which is found throughout much of the AKAudioUnit and related classes
    public func twelveToneEqualTemperament() {
        var nf = [Element](repeatElement(1.0, count: 12))
        for i in 0...11 {
            nf[i] = Element(pow(2.0, Element(Element(i)/12.0)))
        }
        self.tuningTable(fromNumberField: nf)
    }

    
    // numberField is an array of positive numbers that will be converted into a tuning
    // pitch = log2(frequency)
    public func tuningTable(fromNumberField numberField:[Element]) {
        if numberField.count==0 {return}
        let nfOctaveReduce = numberField.map({(number:Element)->Element in
            let l2 = log2(number)
            let m = fmod(l2, 1)
            return m
        })
        let nfOctaveReducedSorted = nfOctaveReduce.sorted {$0 > $1}
        self.numberField = nfOctaveReducedSorted

        updateTuningTable()
    }
    
    // From Erv Wilson
    public func presetRecurrenceRelation01() {
        tuningTable(fromNumberField: [1,34,5,21,3,13,55])
    }
    // From Erv Wilson
    public func presetHighlandBagPipes() {
        tuningTable(fromNumberField: [32,36,39,171,48,52,57])
    }
    
    public func presetPersianNorthIndianMadhubanti() {
        tuningTable(fromNumberField: [1.0,
                                      9.0/8.0,
                                      1215.0/1024.0,
                                      45.0/32.0,
                                      3.0/2.0,
                                      27.0/16.0,
                                      15.0/8.0])
    }
    
    private static let NYQUIST:Element = 22050

    private func updateTuningTable() {
        for i in 0..<AKTuningTable.numberOfMidiNotes {
            let ff = Double(i - Int(noteNumberAtMiddleC)) / Double(AKTuningTable.numberOfMidiNotes)
            var ttOctaveFactor = Double(trunc(ff))
            if ff < 0 {
                ttOctaveFactor -= 1
            }
            var frac = fabs(ttOctaveFactor - ff)
            if frac == 1 {
                frac = 0
                ttOctaveFactor += 1
            }
            let nfIndex = Int(floor(frac * Double(self.numberField.count)))
            let tone = Element(exp2(self.numberField[nfIndex]))
            let oamc = pow(2.0, Double(octaveAtMiddleC))
            let lp2 = pow(oamc, ttOctaveFactor)
            let f = tone * lp2 * frequencyAtMiddleC
            
            //TODO: No good consensus on clamping frequencies
            //if f > NYQUIST {f = AKTuningTable.NYQUIST}
            //if f <= CGFLOAT_MIN {f = CGFLOAT_MIN}
            
            content[i] = Element(f)
        }
    }
}
