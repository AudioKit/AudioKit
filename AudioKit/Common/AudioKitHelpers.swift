//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {
    
    /// Calculate frequency from a MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency() -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * 440.0
    }
}

/// Global function for random integers
///
/// - returns: Random integer in the range
/// - parameter range: Range of valid integers to choose from
///
public func randomInt(range: Range<Int>) -> Int {
    let width = range.maxElement()! - range.minElement()!
    return Int(arc4random_uniform(UInt32(width))) + range.minElement()!
}


/// Extension to Array for Random Element
extension Array {
    
    /// Return a random element from the array
    public func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

/// Global function for random Doubles
///
/// - returns: Random double between bounds
/// - parameter minimum: Lower bound of randomization
/// - parameter maximum: Upper bound of randomization
///
public func random(minimum: Double, _ maximum: Double) -> Double {
    let precision = 1000000
    let width = maximum - minimum
    
    return Double(arc4random_uniform(UInt32(precision))) / Double(precision) * width + minimum
}


