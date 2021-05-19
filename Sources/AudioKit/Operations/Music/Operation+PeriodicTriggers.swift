// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {
    
    /// Metro produces a series of 1-sample ticks at a regular rate. Typically, this
    /// is used alongside trigger-driven modules.
    ///
    /// - parameter frequency: The frequency to repeat. (Default: 2.0)
    ///
    public static func metronome(frequency: OperationParameter = 2.0) -> Operation {
        return Operation(module: "metro", inputs: frequency)
    }

    /// Produce a set of triggers spaced apart by time.
    ///
    /// - parameter period: Time between triggers (in seconds). Updates at the start of each trigger. (Default: 1.0)
    ///
    public static func periodicTrigger(period: OperationParameter = 1.0) -> Operation {
        return Operation(module: "dmetro", inputs: period)
    }
}
