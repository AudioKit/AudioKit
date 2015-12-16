//
//  squareWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    
    /** squareWave: Square wave oscillator -
     - returns: AKParameter
     - Parameter frequency: Frequency in cycles per second (Default: 440)
     - Parameter amplitude: Amplitude of the output (Default: 1)
     - Parameter pulseWidth: Duty cycle width (Default: 0.5, Minimum: 0, Maximum: 1)
     */
    public static func squareWave(
        frequency frequency: AKParameter = 440.ak,
        amplitude: AKParameter = 1.ak,
        pulseWidth: AKParameter = 0.5.ak
        ) -> AKParameter {
            return AKParameter("\(frequency)\(amplitude)\(pulseWidth)square")
    }
}

// Global Helper function

/** squareWave: Square wave oscillator -
- returns: AKParameter
- Parameter frequency: Frequency in cycles per second (Default: 440)
- Parameter amplitude: Amplitude of the output (Default: 1)
- Parameter pulseWidth: Duty cycle width (Default: 0.5, Minimum: 0, Maximum: 1)
*/
public func squareWave(
    frequency frequency: AKParameter = 440.ak,
    amplitude: AKParameter = 1.ak,
    pulseWidth: AKParameter = 0.5.ak
    ) -> AKParameter {
        return AKParameter.squareWave(frequency: frequency, amplitude: amplitude, pulseWidth: pulseWidth)
}