//
//  midiNoteToFrequency.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {
    
    /// Calculate frequency from a MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency(aRef: Double = 440.0) -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * aRef
    }
}

/// Extension to Double to get the frequency from a MIDI Note Number
extension Double {

    /// Calculate frequency from a floating point MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency(aRef: Double = 440.0) -> Double {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }
    
}