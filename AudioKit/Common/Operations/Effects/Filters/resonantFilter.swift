//
//  resonantFilter.swift
//  AudioKit For iOS
//
//  Created by Daniel Clelland on 7/13/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {
    
    /// A second-order resonant filter.
    ///
    /// - Parameters:
    ///   - frequency: The center frequency of the filter, or frequency position of the peak response.
    ///   - bandwidth: The bandwidth of the filter (the Hz difference between the upper and lower half-power points).
    ///
    public func resonantFilter(
        frequency frequency: AKParameter = 100.0,
                  bandwidth: AKParameter = 0.95
        ) -> AKOperation {
        return AKOperation("(\(self.toMono()) \(frequency) \(bandwidth) reson)")
    }
}
