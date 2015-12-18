//
//  squareWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /** squareWave: Square wave oscillator -
     - returns: AKOperation
     - Parameter frequency: Frequency in cycles per second (Default: 440)
     - Parameter amplitude: Amplitude of the output (Default: 1)
     - Parameter pulseWidth: Duty cycle width (Default: 0.5, Minimum: 0, Maximum: 1)
     */
    public static func squareWave(
        frequency frequency: AKOperation = 440.ak,
        amplitude: AKOperation = 1.ak,
        pulseWidth: AKOperation = 0.5.ak
        ) -> AKOperation {
            return AKOperation("\(frequency)\(amplitude)\(pulseWidth)square")
    }
}

// Global Helper function

/** squareWave: Square wave oscillator -
- returns: AKOperation
- Parameter frequency: Frequency in cycles per second (Default: 440)
- Parameter amplitude: Amplitude of the output (Default: 1)
- Parameter pulseWidth: Duty cycle width (Default: 0.5, Minimum: 0, Maximum: 1)
*/
public func squareWave(
    frequency frequency: AKOperation = 440.ak,
    amplitude: AKOperation = 1.ak,
    pulseWidth: AKOperation = 0.5.ak
    ) -> AKOperation {
        return AKOperation.squareWave(frequency: frequency, amplitude: amplitude, pulseWidth: pulseWidth)
}