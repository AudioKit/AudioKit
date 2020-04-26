// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKOperation {

    /// Line segments with vertices at random points
    ///
    /// - Parameters:
    ///   - minimum: Minimum value (Default: 0)
    ///   - maximum: Maximum value (Default: 1)
    ///   - updateFrequency: Frequency to change values. (Default: 3)
    ///
    public static func randomVertexPulse(
        minimum: AKParameter = 0,
        maximum: AKParameter = 1,
        updateFrequency: AKParameter = 3
        ) -> AKOperation {
        return AKOperation(module: "randi",
                           inputs: minimum, maximum, updateFrequency)
    }
}
