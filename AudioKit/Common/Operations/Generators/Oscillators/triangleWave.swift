//
//  triangleWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /** triangleWave: Triangle wave oscillator
     
     - returns: AKOperation
     - parameter frequency: Frequency in cycles per second (Default: 440)
     - parameter amplitude: Amplitude of the output (Default: 1)
     */
    public static func triangleWave(
        frequency frequency: AKOperation = 440.ak,
        amplitude: AKOperation = 1.ak
        ) -> AKOperation {
            return AKOperation("\(frequency)\(amplitude)triangle")
    }
}

// Global Helper function

/** triangleWave: triangle wave oscillator

- returns: AKOperation
- parameter frequency: Frequency in cycles per second (Default: 440)
- parameter amplitude: Amplitude of the output (Default: 1)
*/
public func triangleWave(
    frequency frequency: AKOperation = 440.ak,
    amplitude: AKOperation = 1.ak
    ) -> AKOperation {
        return AKOperation.triangleWave(frequency: frequency, amplitude: amplitude)
}
