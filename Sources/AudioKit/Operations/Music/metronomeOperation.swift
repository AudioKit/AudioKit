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
}
