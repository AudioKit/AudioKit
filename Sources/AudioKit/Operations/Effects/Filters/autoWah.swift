// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// An automatic wah effect, ported from Guitarix via Faust.
    ///
    /// - Parameters:
    ///   - wah: Wah Amount (Default: 0, Minimum: 0, Maximum: 1)
    ///   - amplitude: Overall level (Default: 0.1, Minimum: 0, Maximum: 1)
    ///
    public func autoWah(
        wah: OperationParameter = 0,
        amplitude: OperationParameter = 0.1
        ) -> Operation {
        return Operation(module: "100 autowah",
                           inputs: toMono(), amplitude, wah)
    }
}
