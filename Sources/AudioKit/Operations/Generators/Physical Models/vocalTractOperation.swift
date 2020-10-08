// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Karplus-Strong plucked string instrument.
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    /// NOTE:  This node is CPU intensitve and will drop packet if your buffer size is
    /// too short. It requires at least 64 samples on an iPhone X, for example.
    public static func vocalTract(
        frequency: OperationParameter = 160.0,
        tonguePosition: OperationParameter = 0.5,
        tongueDiameter: OperationParameter = 1.0,
        tenseness: OperationParameter = 0.6,
        nasality: OperationParameter = 0.0) -> Operation {

        return Operation(module: "voc",
                           inputs: frequency, tonguePosition, tongueDiameter, tenseness, nasality)
    }
}
