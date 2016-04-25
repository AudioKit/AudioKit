//
//  segment.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/16/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /// Line Segment to change values over time
    ///
    /// - parameter start: Starting value
    /// - parameter end: Ending value
    /// - parameter duration: Length of time
    ///
    public static func lineSegment(
        trigger: AKOperation,
        start: AKParameter,
        end: AKParameter,
        duration: AKParameter
        ) -> AKOperation {
            return AKOperation("(\(trigger) \(start) \(duration) \(end) line)")
    }
}

extension AKOperation {
    
    /// Exponential Segment to change values over time
    ///
    /// - parameter start: Starting value
    /// - parameter end: Ending value
    /// - parameter duration: Length of time
    ///
    public static func exponentialSegment(
        trigger: AKOperation,
        start: AKParameter,
        end: AKParameter,
        duration: AKParameter
        ) -> AKOperation {
            return AKOperation("(\(trigger) \(start) \(duration) \(end) expon)")
    }
}