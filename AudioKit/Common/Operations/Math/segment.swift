//
//  segment.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Line Segment to change values over time
    ///
    /// - Parameters:
    ///   - start: Starting value
    ///   - end: Ending value
    ///   - duration: Length of time
    ///
    public static func lineSegment(
        trigger: AKOperation,
        start: AKParameter,
        end: AKParameter,
        duration: AKParameter
        ) -> AKOperation {
        return AKOperation(module: "line", inputs: trigger, start, duration, end)
    }
}

extension AKOperation {

    /// Exponential Segment to change values over time
    ///
    /// - Parameters:
    ///   - start: Starting value
    ///   - end: Ending value
    ///   - duration: Length of time
    ///
    public static func exponentialSegment(
        trigger: AKOperation,
        start: AKParameter,
        end: AKParameter,
        duration: AKParameter
        ) -> AKOperation {
        return AKOperation(module: "expon" , inputs: trigger, start, duration, end)
    }
}