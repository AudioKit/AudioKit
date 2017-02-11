//
//  Double+Extensions.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/5/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

// *********************************************************
// MARK: - UI Helper Extensions
// *********************************************************

extension Double {

    // Return string formatted to 2 decimal places
    var decimalString: String {
        return String(format: "%.02f", self)
    }

    // Return string shifted 3 decimal places to left
    var decimal1000String: String {
        let newValue = 1_000 * self
        return String(format: "%.02f", newValue)
    }

    // *********************************************************
    // MARK: - Random Generators
    // *********************************************************

    // return random number between 0.0 and 1.0
    public static func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }

    // return random number in range
    public static func random(min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }

    // return either -1 or 1 randomly
    public static func randomSign() -> Double {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }

    // *********************************************************
    // MARK: - Scale Range
    // *********************************************************

    // Linear scale 0.0 to 1.0 to any range
    public static func scaleRange(_ value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        return ((rangeMax - rangeMin) * (value - 0.0) / (1.0 - 0.0)) + rangeMin
    }

    // Logarithmically scale 0.0 to 1.0 to any range
    public static func scaleRangeLog(_ value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        let scale = (log(rangeMax) - log(rangeMin))
        return exp(log(rangeMin) + (scale * value))
    }
}
