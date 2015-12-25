//
//  triangleWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /** Triangle wave oscillator

     - returns: AKOperation
     - parameter frequency: Frequency in cycles per second (Default: 440)
     - parameter amplitude: Amplitude of the output (Default: 1)
     */
    public static func triangleWave(
        frequency frequency: AKParameter = 440,
        amplitude: AKParameter = 1
        ) -> AKOperation {
            return AKOperation("(\(frequency) \(amplitude) triangle)")
    }
}

// Global Helper function

/** Triangle wave oscillator

- returns: AKOperation
- parameter frequency: Frequency in cycles per second (Default: 440)
- parameter amplitude: Amplitude of the output (Default: 1)
*/
public func triangleWave(
    frequency frequency: AKParameter = 440,
    amplitude: AKParameter = 1
    ) -> AKOperation {
        return AKOperation.triangleWave(frequency: frequency, amplitude: amplitude)
}
