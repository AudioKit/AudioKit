// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
        start: OperationParameter,
        end: OperationParameter,
        duration: OperationParameter
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
        start: OperationParameter,
        end: OperationParameter,
        duration: OperationParameter
        ) -> AKOperation {
        return AKOperation(module: "expon", inputs: trigger, start, duration, end)
    }
}
