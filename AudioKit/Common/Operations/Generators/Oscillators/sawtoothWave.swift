//
//  sawtoothWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /** sawtoothWave: Sawtooth wave oscillator

     - returns: AKOperation
     - parameter frequency: Frequency in cycles per second (Default: 440)
     - parameter amplitude: Amplitude of the output (Default: 1)
     */
    public static func sawtoothWave(
        frequency frequency: AKParameter = 440,
        amplitude: AKParameter = 1
        ) -> AKOperation {
            return AKOperation("(\(frequency) \(amplitude) saw)")
    }
}

// Global Helper function

/** sawtoothWave: Sawtooth wave oscillator

- returns: AKOperation
- parameter frequency: Frequency in cycles per second (Default: 440)
- parameter amplitude: Amplitude of the output (Default: 1)
*/
public func sawtoothWave(
    frequency frequency: AKParameter = 440,
    amplitude: AKParameter = 1
    ) -> AKOperation {
        return AKOperation.sawtoothWave(frequency: frequency, amplitude: amplitude)
}
