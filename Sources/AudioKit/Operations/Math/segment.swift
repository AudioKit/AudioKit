// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Line Segment to change values over time
    ///
    /// - Parameters:
    ///   - start: Starting value
    ///   - end: Ending value
    ///   - duration: Length of time
    ///
    public static func lineSegment(
        trigger: Operation,
        start: OperationParameter,
        end: OperationParameter,
        duration: OperationParameter
        ) -> Operation {
        return Operation(module: "line", inputs: trigger, start, duration, end)
    }
}

extension Operation {

    /// Exponential Segment to change values over time
    ///
    /// - Parameters:
    ///   - start: Starting value
    ///   - end: Ending value
    ///   - duration: Length of time
    ///
    public static func exponentialSegment(
        trigger: Operation,
        start: OperationParameter,
        end: OperationParameter,
        duration: OperationParameter
        ) -> Operation {
        return Operation(module: "expon", inputs: trigger, start, duration, end)
    }
}
