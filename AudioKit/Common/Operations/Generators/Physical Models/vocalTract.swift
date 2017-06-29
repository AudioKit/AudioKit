//
//  vocalTract.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKOperation {

    /// Karplus-Strong plucked string instrument.
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    public static func vocalTract(
        frequency: AKParameter = 160.0,
        tonguePosition: AKParameter = 0.5,
        tongueDiameter: AKParameter = 1.0,
        tenseness: AKParameter = 0.6,
        nasality: AKParameter = 0.0) -> AKOperation {

        return AKOperation(module: "voc",
                           inputs: frequency, tonguePosition, tongueDiameter, tenseness, nasality)
    }
}
