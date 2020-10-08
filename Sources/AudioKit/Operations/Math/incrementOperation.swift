// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Increment a signal by a default value of 1
    ///
    /// - Parameters:
    ///   - on: When to increment
    ///   - by: Increment amount (Default: 1)
    ///   - minimum: Increment amount (Default: 1)
    ///   - maximum: Increment amount (Default: 1)
    ///
    public func increment(on trigger: OperationParameter,
                          by step: OperationParameter = 1.0,
                          minimum: OperationParameter = 0.0,
                          maximum: OperationParameter = 1_000_000) -> Operation {
        return Operation(module: "incr", inputs: trigger, step, minimum, maximum, toMono())
    }
}
