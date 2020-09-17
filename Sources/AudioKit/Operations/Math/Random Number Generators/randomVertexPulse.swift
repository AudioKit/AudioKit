// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Line segments with vertices at random points
    ///
    /// - Parameters:
    ///   - minimum: Minimum value (Default: 0)
    ///   - maximum: Maximum value (Default: 1)
    ///   - updateFrequency: Frequency to change values. (Default: 3)
    ///
    public static func randomVertexPulse(
        minimum: OperationParameter = 0,
        maximum: OperationParameter = 1,
        updateFrequency: OperationParameter = 3
        ) -> Operation {
        return Operation(module: "randi",
                           inputs: minimum, maximum, updateFrequency)
    }
}
