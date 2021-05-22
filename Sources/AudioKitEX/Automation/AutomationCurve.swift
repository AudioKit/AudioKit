// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

import Foundation

/// An automation curve (with curved segments) suitable for any time varying parameter.
/// Includes functions for manipulating automation curves and conversion to linear automation ramps
/// used by DSP code.
public struct AutomationCurve {

    /// Shorter name
    public typealias Point = ParameterAutomationPoint

    /// Array of points that make up the curve
    public var points: [Point]


    /// Initialize with points
    /// - Parameter points: Array of points
    public init(points: [Point]) {
        self.points = points
    }

    static func evalRamp(start: Float,
                         segment: Point,
                         time: Float,
                         endTime: Float) -> Float {
        let remain = endTime - time
        let taper = segment.rampTaper
        let goal = segment.targetValue

        // x is normalized position in ramp segment
        let x = (segment.rampDuration - remain) / segment.rampDuration
        let taper1 = start + (goal - start) * pow(x, abs(taper))
        let absxm1 = abs((segment.rampDuration - remain) / segment.rampDuration - 1.0)
        let taper2 = start + (goal - start) * (1.0 - pow(absxm1, 1.0 / abs(taper)))

        return taper1 * (1.0 - segment.rampSkew) + taper2 * segment.rampSkew
    }

    /// Returns a new piecewise-linear automation curve which can be handed off to the audio thread
    /// for efficient processing.
    ///
    /// - Parameters:
    ///   - initialValue: Starting point
    ///   - resolution: Duration of each linear segment in seconds
    ///
    /// - Returns: A new array of piecewise linear automation points
    public func evaluate(initialValue: AUValue,
                         resolution: Float) -> [AutomationEvent] {

        var result = [AutomationEvent]()

        // The last evaluated value
        var value = initialValue

        for i in 0 ..< points.count {
            let point = points[i]

            if point.isLinear() {

                result.append(AutomationEvent(targetValue: point.targetValue,
                                                startTime: point.startTime,
                                                rampDuration: point.rampDuration))
                value = point.targetValue

            } else {

                // Cut off the end if another point comes along.
                let nextPointStart = i < points.count - 1 ? points[i + 1].startTime
                                                          : Float.greatestFiniteMagnitude
                let endTime: Float = min(nextPointStart,
                                         point.startTime + point.rampDuration)

                var t = point.startTime
                let start = value

                // March t along the segment
                // this is effectively `while t <= endTime - resolution` without potentional for rounding errors
                for _ in 0 ..< Int(round(endTime / resolution)) {

                    value = AutomationCurve.evalRamp(start: start,
                                                       segment: point,
                                                       time: t + resolution,
                                                       endTime: point.startTime + point.rampDuration)

                    result.append(AutomationEvent(targetValue: value,
                                                    startTime: t,
                                                    rampDuration: resolution))

                    t += resolution
                }
            }

        }

        return result
    }

    /// Replaces automation over a time range.
    ///
    /// Use this when calculating a new automation curve after recording automation.
    ///
    /// - Parameters:
    ///   - range: time range
    ///   - withPoints: new automation events
    /// - Returns: new automation curve
    public func replace(range: ClosedRange<Float>, withPoints newPoints: [(Float, AUValue)]) -> AutomationCurve {

        var result = points
        let startTime = range.lowerBound
        let stopTime = range.upperBound

        // Clear existing points in segment range.
        result.removeAll { point in
            point.startTime >= startTime && point.startTime <= stopTime
        }

        // Append recorded points.
        result.append(contentsOf: newPoints.map { point in
            Point(targetValue: point.1, startTime: point.0, rampDuration: 0.01)
        })

        // Sort vector by time.
        result.sort { $0.startTime < $1.startTime }

        return AutomationCurve(points: result)

    }

}
