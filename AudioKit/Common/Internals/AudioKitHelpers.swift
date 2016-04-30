//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

// MARK: - Randomization Helpers

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

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension Double {
    
    /// Convert a value on [min, max] to a [0, 1] range, according to a taper
    ///
    /// - parameter min: Minimum of the source range (cannot be zero if taper is not positive)
    /// - parameter max: Maximum of the source range
    /// - parameter taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func normalize(min: Double, max: Double, taper: Double) {
        if taper > 0 {
            // algebraic taper
            self = pow(((self - min) / (max - min)), (1.0 / taper))
        } else {
            // exponential taper
            self = log(self / min) / log(max / min)
        }
    }
    
    /// Convert a value on [0, 1] to a [min, max] range, according to a taper
    ///
    /// - parameter min: Minimum of the target range (cannot be zero if taper is not positive)
    /// - parameter max: Maximum of the target range
    /// - parameter taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func denormalize(min: Double, max: Double, taper: Double) {
        if taper > 0 {
            // algebraic taper
            self = min + (max - min) * pow(self, taper)
        } else {
            // exponential taper
            self = min * exp(log(max / min) * self)
        }
    }
}
